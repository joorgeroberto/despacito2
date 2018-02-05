package pasito.syntax;

import java_cup.runtime.*;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.io.*;
import java_cup.runtime.ComplexSymbolFactory;

class Driver {
	    /**
	     * @param args the command line arguments
	     * @throws IOException
	     */
	    public static void main(String[] args) throws IOException {
	    
	        ComplexSymbolFactory csf = new ComplexSymbolFactory();
	        PasitoScanner lexical = new PasitoScanner(new BufferedReader(new FileReader("input.txt")), csf);
	        ComplexSymbolFactory.ComplexSymbol next_token;
	        next_token = (ComplexSymbolFactory.ComplexSymbol) lexical.next_token();
	        while (next_token.sym != 0) {
	            System.out.println("<"+ next_token.getName() + ", " +next_token.value+ ">");
	            try {
		            next_token = (ComplexSymbolFactory.ComplexSymbol)lexical.next_token();
	            } catch (Exception e) { break; }
	        }
	    
	}

	
}