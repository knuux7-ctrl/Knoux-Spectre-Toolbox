using namespace System.Net.Http
using namespace System.Text

class AIIntegrationSystem {
    [string] $DefaultProvider
    [hashtable] $Providers
    [HttpClient] $HttpClient
    [int] $TimeoutSeconds
    [bool] $UseLocalModels
    [string] $LocalModelPath
    
    AIIntegrationSystem([string]$defaultProvider = "openai") {
        $this.DefaultProvider = $defaultProvider
        $this.Providers = @{}
        $this.HttpClient = New-Object HttpClient
        $this.TimeoutSeconds = 30
        $this.UseLocalModels = $global:ConfigManager.Get("ai.use_local_models", $false)
        $this.LocalModelPath = $global:ConfigManager.Get("ai.local_model_path", "./models/")
        $this.InitializeProviders()
    }
    
    [void] InitializeProviders() {
        # OpenAI Provider
        $this.Providers["openai"] = @{
            api_base = "https://api.openai.com/v1"
            api_key  = $global:ConfigManager.Get("ai.providers.openai.api_key", "")
            models   = @("gpt-3.5-turbo", "gpt-4")
        }
        
        # Anthropic Provider
        $this.Providers["anthropic"] = @{
            api_base = "https://api.anthropic.com/v1"
            api_key  = $global:ConfigManager.Get("ai.providers.anthropic.api_key", "")
            models   = @("claude-3-opus", "claude-3-sonnet")
        }
        
        # Local HuggingFace Models
        $this.Providers["huggingface"] = @{
            api_base = "https://api-inference.huggingface.co/models"
            api_key  = $global:ConfigManager.Get("ai.providers.huggingface.api_key", "")
            models   = @("meta-llama/Llama-2-7b-chat-hf", "google/gemma-2b-it")
        }
        
        Write-Verbose "🧠 AI providers initialized: $($this.Providers.Keys -join ', ')"
    }
    
    [object] GenerateCompletion([string]$prompt, [hashtable]$options = @{}) {
        $provider = $options.provider ?: $this.DefaultProvider
        $model = $options.model ?: $this.Providers[$provider].models[0]
        $temperature = $options.temperature ?: 0.7
        $maxTokens = $options.max_tokens ?: 1000
        $timeout = $options.timeout ?: $this.TimeoutSeconds
        
        try {
            Write-Host "🤖 Processing with $provider ($model)..." -ForegroundColor Magenta
            
            # Track execution time
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            $result = if ($this.UseLocalModels) {
                $this.GenerateLocalCompletion($prompt, $model, $temperature, $maxTokens)
            }
            else {
                $this.GenerateRemoteCompletion($prompt, $provider, $model, $temperature, $maxTokens, $timeout)
            }
            
            $stopwatch.Stop()
            
            # Log interaction
            if ($global:ReportingSystem) {
                $global:ReportingSystem.LogAIInteraction(
                    $prompt, 
                    $result.choices[0].message.content, 
                    $stopwatch.Elapsed.TotalSeconds, 
                    $true
                )
            }
            
            return $result
            
        }
        catch {
            Write-Warning "AI completion failed: $($_.Exception.Message)"
            
            # Log failed interaction
            if ($global:ReportingSystem) {
                $global:ReportingSystem.LogAIInteraction($prompt, "", 0, $false)
            }
            
            # Return fallback response
            return @{
                choices = @(@{
                        message = @{
                            content = "I apologize, but I encountered an error processing your request: $($_.Exception.Message)"
                        }
                    })
                usage   = @{
                    total_tokens = 0
                }
            }
        }
    }
    
    [object] GenerateRemoteCompletion([string]$prompt, [string]$provider, [string]$model, [double]$temperature, [int]$maxTokens, [int]$timeout) {
        $providerConfig = $this.Providers[$provider]
        if (-not $providerConfig) {
            throw "Provider $provider not configured"
        }
        
        if (-not $providerConfig.api_key) {
            throw "API key not configured for provider $provider"
        }
        
        $httpClient = New-Object HttpClient
        $httpClient.Timeout = [TimeSpan]::FromSeconds($timeout)
        
        $headers = switch ($provider) {
            "openai" {
                @{
                    "Authorization" = "Bearer $($providerConfig.api_key)"
                    "Content-Type"  = "application/json"
                }
            }
            "anthropic" {
                @{
                    "x-api-key"         = $providerConfig.api_key
                    "Content-Type"      = "application/json"
                    "anthropic-version" = "2023-06-01"
                }
            }
            "huggingface" {
                @{
                    "Authorization" = "Bearer $($providerConfig.api_key)"
                }
            }
        }
        
        foreach ($header in $headers.GetEnumerator()) {
            $httpClient.DefaultRequestHeaders.Add($header.Key, $header.Value)
        }
        
        $payload = switch ($provider) {
            "openai" {
                @{
                    model       = $model
                    messages    = @(@{ role = "user"; content = $prompt })
                    temperature = $temperature
                    max_tokens  = $maxTokens
                } | ConvertTo-Json -Depth 10
            }
            "anthropic" {
                @{
                    model       = $model
                    messages    = @(@{ role = "user"; content = $prompt })
                    temperature = $temperature
                    max_tokens  = $maxTokens
                } | ConvertTo-Json -Depth 10
            }
            "huggingface" {
                @{
                    inputs     = $prompt
                    parameters = @{
                        max_new_tokens = $maxTokens
                        temperature    = $temperature
                    }
                } | ConvertTo-Json -Depth 10
            }
        }
        
        $content = New-Object StringContent($payload, [Encoding]::UTF8, "application/json")
        $url = switch ($provider) {
            "openai" { "$($providerConfig.api_base)/chat/completions" }
            "anthropic" { "$($providerConfig.api_base)/messages" }
            "huggingface" { "$($providerConfig.api_base)/$model" }
        }
        
        $response = $httpClient.PostAsync($url, $content).Result
        $responseContent = $response.Content.ReadAsStringAsync().Result
        
        if ($response.IsSuccessStatusCode) {
            $jsonResponse = $responseContent | ConvertFrom-Json
            
            # Normalize response format
            $normalizedResponse = switch ($provider) {
                "openai" { $jsonResponse }
                "anthropic" {
                    @{
                        choices = @(@{
                                message = @{
                                    content = $jsonResponse.content[0].text
                                }
                            })
                        usage   = @{
                            total_tokens = $jsonResponse.usage.output_tokens
                        }
                    }
                }
                "huggingface" {
                    @{
                        choices = @(@{
                                message = @{
                                    content = $jsonResponse[0].generated_text
                                }
                            })
                        usage   = @{
                            total_tokens = $jsonResponse[0].generated_text.Length / 4 # Approximation
                        }
                    }
                }
            }
            
            return $normalizedResponse
        }
        else {
            throw "API request failed with status $($response.StatusCode): $responseContent"
        }
    }
    
    [object] GenerateLocalCompletion([string]$prompt, [string]$model, [double]$temperature, [int]$maxTokens) {
        # This would require a local model server (like Ollama, llama.cpp, etc.)
        # Placeholder for local inference implementation
        
        $modelPath = Join-Path $this.LocalModelPath "$model.bin"
        if (-not (Test-Path $modelPath)) {
            throw "Local model not found: $modelPath"
        }
        
        # Example: Integration with Ollama (if available)
        $ollamaCheck = Get-Command ollama -ErrorAction SilentlyContinue
        if ($ollamaCheck) {
            try {
                $response = & ollama run $model `
                    "--prompt='$prompt'" `
                    "--temperature=$temperature" `
                    "--max-tokens=$maxTokens" 2>&1
                
                return @{
                    choices = @(@{
                            message = @{
                                content = $response -join "`n"
                            }
                        })
                    usage   = @{
                        total_tokens = $response.Length / 4 # Approximation
                    }
                }
            }
            catch {
                throw "Ollama inference failed: $($_.Exception.Message)"
            }
        }
        else {
            throw "Local model inference not available. Please install ollama or configure remote providers."
        }
    }
    
    [object] ProcessWithFunctionCalling([string]$prompt, [object[]]$functions) {
        # Enhanced completion with function calling capability
        $messages = @(
            @{ role = "system"; content = "You are a helpful AI assistant with function calling capabilities." }
            @{ role = "user"; content = $prompt }
        )
        
        $provider = $this.DefaultProvider
        $model = $this.Providers[$provider].models | Where-Object { $_ -like "*function*" } | Select-Object -First 1
        $model = $model ?: $this.Providers[$provider].models[0]
        
        # Build function definitions
        $functionDefs = $functions | ForEach-Object {
            @{
                name        = $_.name
                description = $_.description
                parameters  = $_.parameters
            }
        }
        
        # In a real implementation, this would use proper function calling APIs
        $response = $this.GenerateCompletion($prompt, @{ provider = $provider; model = $model })
        
        # Parse function calls from response (simplified version)
        $responseContent = $response.choices[0].message.content
        if ($responseContent -match "<function_call>(.*?)</function_call>") {
            $functionCalls = $matches[1] | ConvertFrom-Json
            return @{
                type     = "function_call"
                calls    = $functionCalls
                response = $response
            }
        }
        
        return @{
            type     = "completion"
            response = $response
        }
    }
    
    [object] MultiModalProcessing([string]$prompt, [object[]]$mediaInputs) {
        # Process text + images/audio/files together
        Write-Host "🎨 Processing multimodal input..." -ForegroundColor Cyan
        
        # In a real implementation, this would handle base64 encoded media
        $enhancedPrompt = $prompt
        if ($mediaInputs) {
            $enhancedPrompt += "`n`nInput contains: "
            $enhancedPrompt += ($mediaInputs | ForEach-Object { $_.type }) -join ", "
        }
        
        return $this.GenerateCompletion($enhancedPrompt)
    }
    
    [hashtable] GetProviderInfo([string]$provider = $null) {
        $providers = if ($provider) {
            @{ $provider = $this.Providers[$provider] }
        }
        else {
            $this.Providers
        }
        
        $info = @{}
        foreach ($prov in $providers.GetEnumerator()) {
            $info[$prov.Key] = @{
                models     = $prov.Value.models
                configured = [bool]($prov.Value.api_key)
                has_key    = $prov.Value.api_key.Length -gt 10 # Check if looks like a real key
            }
        }
        return $info
    }
    
    [object] StreamCompletion([string]$prompt, [hashtable]$options = @{}, [scriptblock]$callback) {
        # Real-time streaming of AI responses (for supported providers)
        Write-Host "🌊 Streaming AI response..." -ForegroundColor Blue
        
        $response = $this.GenerateCompletion($prompt, $options)
        $content = $response.choices[0].message.content
        
        # Simulate streaming by breaking response into chunks
        $chunks = $content -split '(.{20,50}\s|\S{50})' | Where-Object { $_.Trim() }
        
        foreach ($chunk in $chunks) {
            if ($chunk.Trim()) {
                & $callback $chunk
                Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 200)
            }
        }
        
        return $response
    }
    
    [object] CodeGeneration([string]$task, [string]$language = "powershell") {
        $codePrompts = @{
            powershell = "Write PowerShell code to accomplish this task: $task`nReturn only executable code without explanation."
            python     = "Write Python code to accomplish this task: $task`nReturn only executable code without explanation."
            javascript = "Write JavaScript code to accomplish this task: $task`nReturn only executable code without explanation."
        }
        
        $prompt = $codePrompts[$language] ?: $codePrompts.powershell
        $response = $this.GenerateCompletion($prompt)
        
        return @{
            code        = $response.choices[0].message.content
            language    = $language
            explanation = "Generated $language code for: $task"
        }
    }
    
    [object] AnalyzeAndSuggestFix([string]$code, [string]$error = "") {
        $prompt = @"
Analyze this code and suggest fixes:

```
$code
```

$error

Please provide:
1. Issues identified
2. Specific fix suggestions
3. Explanation of why issues occur
4. Optimized code if improvements are possible
"@
        
        return $this.GenerateCompletion($prompt)
    }
    
    [void] BatchProcess([string[]]$prompts, [scriptblock]$resultCallback) {
        # Process multiple prompts efficiently
        $tasks = foreach ($prompt in $prompts) {
            [System.Threading.Tasks.Task]::Run({
                    try {
                        return $this.GenerateCompletion($prompt)
                    }
                    catch {
                        return @{ error = $_.Exception.Message }
                    }
                })
        }
        
        [System.Threading.Tasks.Task]::WaitAll($tasks)
        
        $results = $tasks | ForEach-Object { $_.Result }
        for ($i = 0; $i -lt $prompts.Count; $i++) {
            & $resultCallback $prompts[$i] $results[$i]
        }
    }
}

# Initialize global AI system
$global:AISystem = [AIIntegrationSystem]::new("openai")
