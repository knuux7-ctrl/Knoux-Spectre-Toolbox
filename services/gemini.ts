
import { GoogleGenAI, Type } from "@google/genai";

export class GeminiService {
  private ai: GoogleGenAI;

  constructor() {
    // Fix: Use process.env.API_KEY directly as per guidelines
    this.ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  }

  async generateCode(prompt: string, language: 'powershell' | 'python' | 'batch') {
    try {
      const response = await this.ai.models.generateContent({
        model: 'gemini-3-pro-preview',
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
    // Simulated "AI Insight" into system health
    try {
      const response = await this.ai.models.generateContent({
        model: 'gemini-3-flash-preview',
        contents: `Based on these system metrics: ${mockStatus}, provide a one-paragraph professional analysis of system health and one recommendation.`,
      });
      return response.text;
    } catch (error) {
      return "Unable to provide AI insights at this time.";
    }
  }
}

export const geminiService = new GeminiService();
