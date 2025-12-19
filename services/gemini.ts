
import { GoogleGenAI, Type } from "@google/genai";

export class GeminiService {
  private ai: GoogleGenAI | null = null;

  constructor() {
    const apiKey = process.env.API_KEY || process.env.GEMINI_API_KEY;
    if (apiKey) {
      this.ai = new GoogleGenAI({ apiKey });
    }
  }

  isConfigured(): boolean {
    return this.ai !== null;
  }

  async generateCode(prompt: string, language: 'powershell' | 'python' | 'batch') {
    if (!this.ai) {
      throw new Error("Gemini API key not configured. Please set GEMINI_API_KEY environment variable.");
    }
    try {
      const response = await this.ai.models.generateContent({
        model: 'gemini-2.0-flash',
        contents: `Generate a robust ${language} script for the following task: ${prompt}. 
                   The script should include proper headers, comments, and follow professional best practices. 
                   Ensure the output is ONLY the code block.`,
        config: {
          temperature: 0.2,
          topP: 0.95,
        }
      });
      
      return response.text;
    } catch (error) {
      console.error("Gemini Code Generation Error:", error);
      throw error;
    }
  }

  async auditSystem(mockStatus: string) {
    if (!this.ai) {
      return "AI insights unavailable. Please configure GEMINI_API_KEY.";
    }
    try {
      const response = await this.ai.models.generateContent({
        model: 'gemini-2.0-flash',
        contents: `Based on these system metrics: ${mockStatus}, provide a one-paragraph professional analysis of system health and one recommendation.`,
      });
      return response.text;
    } catch (error) {
      return "Unable to provide AI insights at this time.";
    }
  }
}

export const geminiService = new GeminiService();
