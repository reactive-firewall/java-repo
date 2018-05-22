package org.javarepo;
import java.util.concurrent.RejectedExecutionException;
import java.lang.Runnable;
import java.util.Scanner;
import java.io.InputStream;
import java.io.File;

/**
 * A class to interface with an internal tool. Primarily for use with UNIX and
 * Linux environments. This class primarily provides the boilerplate code for 
 * {@link java.lang.Runtime#exec(java.lang.String, java.lang.String[], java.io.File)}.
 * EXAMPLE CODE IS FROM PAK - programming accessory kit.
 * @author Kendrick Walls
 * @version 20120921
 * @since 20120622
 */
public class InternalTool {
    
    /**
    Debug Mode.
    */
    private static boolean ISDEBUGMODE = false;
    

    /**
     @return string the tool's output text.
     @see java.lang.System#getProperty(java.lang.String)
     @throws java.util.concurrent.RejectedExecutionException on error.
     @since 20180522
    */
    public static java.lang.String getPWD(){
        java.lang.String pwd;
        try {
            pwd = java.lang.System.getProperty("user.dir", new java.lang.String("/").intern());
        }
        catch (SecurityException secErr) {
            if ( org.javarepo.InternalTool.ISDEBUGMODE ) {
                System.out.println("User is in a directory Java can't access! - System may be hardened.");
            };
            try {
                 pwd = java.lang.System.getProperty("java.io.tmpdir", new java.lang.String("/").intern());
            }
            catch (SecurityException secondErr) {
                if ( org.javarepo.InternalTool.ISDEBUGMODE ) {
                    System.out.println("Java can't access temp! - System may be sand-boxed.");
                };
                pwd = new java.lang.String("/").intern();
            }//SecurityException
        }//SecurityException
        return pwd;
    }

    /**
     Runs a given command and returns the output. Provides more boilerplate code than
     {@link java.lang.Runtime#exec(java.lang.String, java.lang.String[], java.io.File) exec(String, String[], File)}
     including i/o handling. If no output is emitted by the command the string
     <code>NULL</code> will be returned. The command will attempt to run in the 
     user's current directory as per the system property <code>user.dir</code>,
     unless there is an error while ascertaining the user's directory. If there 
     is an error determining the user's current directory then the command will
     attempt to run in either the value of the system property
     <code>java.io.tmpdir</code>, or the root directory.
     CODE IS FROM PAK - programming accessory kit.
     @param someTool The full tool's command text.
     @return string the tool's output text.
     @see java.lang.System#getProperty(java.lang.String)
     @throws java.util.concurrent.RejectedExecutionException on error.
     @since 20130302
     */
    public static java.lang.String useInternalTool(java.lang.String someTool)
    {
    /* the path to the working directory */
    java.lang.String pwd = getPWD();

    /* at this point the pwd should be valid */
    try {
        pwd = new java.io.File(pwd).getCanonicalPath().intern();
    }
    catch (java.io.IOException noSuchFile){
        //throw noSuchFile;
        pwd = new java.lang.String("/").intern();
    }
    
    /*
     at this point the working directory of the internal command will be the
     value of pwd.
     */
    
    java.lang.String data = new java.lang.String("").intern();
    try {
        java.util.Scanner input;
        
        java.lang.String theCommand = new java.lang.String( someTool ).intern();
        
        if ( org.javarepo.InternalTool.ISDEBUGMODE ) {
            System.out.println("Running: " + someTool);
        };
        
        try {
            
            
            java.lang.Process theInternalProc =
            java.lang.Runtime.getRuntime().exec(theCommand, null, new java.io.File(pwd));
            
            try {
                input = new java.util.Scanner( new java.io.BufferedInputStream(theInternalProc.getInputStream()) );
                
                boolean isNotDone = true;
                
                /*
                 
                 Absolutely DO NOT call a java.lang.Thread.yield();  here
                 See java.lang.Runtime.getRuntime().exec(java.lang.String)
                 
                 ...it WILL misbehave
                 
                 */
                
                while (isNotDone) {
                    try {
                        theInternalProc.waitFor();
                        isNotDone = false;
                }
                catch (java.lang.InterruptedException swapErr)
                {
                    isNotDone = true;
                }
                
                }
                    
                    if (theInternalProc.exitValue() == 0)
                        {
                        if ( org.javarepo.InternalTool.ISDEBUGMODE ) System.out.println("Success " + theInternalProc.exitValue());
                    }
                    else {
                        System.err.println("Unknown Error: " + theInternalProc.exitValue());
                    }
                    
            }
            catch (Exception procErr) {
                // catch the baton if any
                RuntimeException theBaton =
                new java.lang.RuntimeException("Shell Script Error!",
                                               procErr);
                theBaton.fillInStackTrace();
                
                if ( org.javarepo.InternalTool.ISDEBUGMODE ) {
                    System.err.println("Shell Script Error!");
                    System.err.println("Sending exit signal");
                };
                theInternalProc.destroy();
                // now toss the baton
                throw theBaton;
            }
            
            
            //input.useDelimiter("\n");
            if (input != null){
                try // read records from file using Scanner object
                {
                synchronized (input)
                    {
                    while ( input.hasNextLine() )
                        {
                        // parse record contents
                        String subtemp = input.nextLine();
                        data += subtemp;
                        if (input.hasNextLine()) data += "\n";
                        } // end while
                    }
                } // end try
                catch ( java.util.NoSuchElementException elementException )
                {
                System.err.println( "Process output improperly formed." );
                System.err.println("Sending exit code to Internal Shell Script");
                //System.exit( 1 );
                } // end catch
                catch ( IllegalStateException stateException )
                {
                System.err.println( "Error reading text from Process." );
                System.err.println("Sending exit code to Internal Shell Script");
                //System.exit( 1 );
                } // end catch
                finally {
                    input.close();
                    theInternalProc.destroy();
                }
            }
            if (data == null || data.trim().length() <= 0) data = "NULL";
            
        }
        catch (java.io.IOException ioErr)
        {
        
        // catch the baton if any
        RuntimeException theBaton =
        new java.lang.RuntimeException("Internal Shell Script i/o Error!",
                                       ioErr);
        theBaton.fillInStackTrace();
        
        /*
         
         JUSTIFICATION OF END-USER ERROR
         1. recovery is not straight-forward.
         2. of the possible recovery options, either:
         a. this code would violate the security of others,
         b. OR this code would be knowingly susceptible to insertion attack and
         THUS BE NEGLIGENT
         3. recovery is only necessary in un-configured installation
         (i.e. installing user's fault)
         4. I can not in good conscience code a deliberately negligent error
         correction. Errors have already occurred, and thus what is know is that
         assumptions are already wrong, so attempting to recover may just cause
         more errors and becomes a dangerous and difficult debugging process. 
         
         */
        System.err.println("Internal Shell Script i/o Error!");
        // might use someTool.split(" ")[0] for name ... 
        System.err.println("Command is NOT in user's shell PATH scope.");

         System.err.println("DEBUG MODE: Will continue to allow debugging!");
         // now toss the original error baton
         throw (java.util.concurrent.RejectedExecutionException)(theBaton);
         
        
        } // end catch
    }
    catch (Exception err)
        {
        RuntimeException theBaton =
        new java.lang.RuntimeException("Internal Tool Error!", err);
        theBaton.fillInStackTrace();
        data = "ERROR!";
        throw (java.util.concurrent.RejectedExecutionException)(theBaton);
        }
    finally
        {
        return data;
        }
    }
    
    /* Colossians 3:23: Work hard and cheerfully at what ever you do,
     as though you were working for the Lord rather than for people.  */
    
}
