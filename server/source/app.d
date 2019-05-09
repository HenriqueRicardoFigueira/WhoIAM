module app;void main() {
   import std.socket; 
   import std.stdio;
   auto listener = new Socket(AddressFamily.INET, SocketType.STREAM);
   listener.bind(new InternetAddress("localhost", 2525));
   listener.listen(10);
   auto readSet = new SocketSet();
   Socket[] connectedClients;
   char[1024] buffer;
   bool isRunning = true;
   while(isRunning) {
       readSet.reset();
       readSet.add(listener);
       foreach(client; connectedClients) readSet.add(client);
       if(Socket.select(readSet, null, null)) {
          foreach(client; connectedClients)
            if(readSet.isSet(client)) {
                // read from it and echo it back
                auto got = client.receive(buffer);
                client.send(buffer[0 .. got]);
            }
          if(readSet.isSet(listener)) {
             // the listener is ready to read, that means
             // a new client wants to connect. We accept it here.
             auto newSocket = listener.accept();
             newSocket.send("Hello!\n"); // say hello
             connectedClients ~= newSocket; // add to our list
             writeln("CLiente said:",  buffer[0 .. newSocket.receive(buffer)]);
             
          }
       }
   }
}

