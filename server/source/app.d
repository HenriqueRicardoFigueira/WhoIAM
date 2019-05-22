module app;
import std.socket;
import std.stdio;

final class Player
{
   string name;
   string ip;
   int score;
   bool master;
   bool token;

   this(string name)
   {
      this.name = name;
      this.score = 0;
      this.token = false;
   }

   string getName()
   {
      return name;
   }

   void setToken(bool tok)
   {
      this.token = tok;
   }

   bool getToken()
   {
      return token;
   }

   void setMaster(bool xxx)
   {
      this.master = xxx;
   }

   bool getMaster()
   {
      return master;
   }

   void setScore()
   {
      this.score += 10;
   }

   string getIp()
   {
      return ip;
   }

   void setIp(string ip)
   {
      this.ip = ip;
   }
}

final class Game
{
   int rodada;
   Player[] players;
   string playerDaVez;
   string master;
   private char[] xvideos;

   this()
   {
      this.rodada = 0;
   }

   int getRodada()
   {
      return rodada;
   }

   void setRodada()
   {
      this.rodada += 1;
   }

   Player[] getPlayers()
   {
      return players;
   }

   void setPlayer(Player id)
   {
      this.players ~= id;
   }

   string getMaster()
   {
      return master;
   }

   void setMaster(string name)
   {
      this.master = name;
   }

   char[] getResposta()
   {
      return xvideos;
   }

   void setResposta(char[] joao)
   {
      writeln("alterei");
      this.xvideos = joao;
   }

   string getPlayersDaVez()
   {
      return playerDaVez;
   }

   void setPlayerDaVez(string name)
   {
      this.playerDaVez = name;
   }

   bool checkWiner(char[] dica)
   {
       
      writeln(getResposta());
      if (dica == getResposta())
      {
         return true;
      }
      dica.destroy();
      return false;
   }

   int returnId(string name)
   {
      int id = 0;
      foreach (Player p1; players)
      {
         if (name == p1.name)
            break;
         id++;
      }
      return id;
   }
}
void sendToAll(Socket[] socketlist, string message){
   foreach (clientss; socketlist){
      clientss.send(message);
   }
}
void main()
{

   auto listener = new Socket(AddressFamily.INET, SocketType.STREAM);
   listener.bind(new InternetAddress("localhost", 8080));
   listener.listen(10);
   auto readSet = new SocketSet();
   Socket[] connectedClients;
   char[1024] buffer;
   bool isRunning = true;
   Game game = new Game();
   char[200] pergunta;
   char[200] mestrep;
   bool verifik = false;
   int id = 1;
   int mestre = 0;
   string[] listaTeste = ["joao", "higor", "henri"];
   while (isRunning)
   {
      readSet.reset();
      readSet.add(listener);
      foreach (client; connectedClients)
         readSet.add(client);
      if (Socket.select(readSet, null, null))
      {
         /*
         foreach (client; connectedClients)
            if (readSet.isSet(client))
            {
               // read from it and echo it back
               auto got = client.receive(buffer);
               client.send(buffer[0 .. got]);
               
            }*/
         if (readSet.isSet(listener))
         {
            // the listener is ready to read, that means
            // a new client wants to connect. We accept it here.
            auto newSocket = listener.accept();
            newSocket.send("Hello mother fuck!\n"); // say hello
            connectedClients ~= newSocket; // add to our list

            Player p1 = new Player(cast(string) buffer[0 .. newSocket.receive(buffer)]);
            if (connectedClients.length == 1)
            {
               p1.setMaster(true);
               p1.setIp(newSocket.remoteAddress().toAddrString());
               //game.setPlayer(p1);
               game.setMaster(p1.getName());
               newSocket.send("true");
               auto x = mestrep[0 .. newSocket.receive(mestrep)];
               game.setResposta(x);
               writeln("resposta do mano");
               writeln(game.getResposta());
            }
            else
            {
               //game.setPlayer(p1);
               p1.setIp(newSocket.remoteAddress().toAddrString());
               newSocket.send("Aguardando Jogadores");
               if (connectedClients.length >= 3)
               {
                  foreach (clientss; connectedClients)
                  {
                     clientss.send("start");
                  }
                  break;
               }
            }
         }
      }
   }

   //Player[] list = game.getPlayers();
   char[200] aleatorio;
   while (true)
   {
      connectedClients[id].send("1");
      auto kk = pergunta[0 .. connectedClients[id].receive(pergunta)];
      //writeln(pergunta);
      connectedClients[mestre].send(kk);
      //sendToAll(connectedClients,cast(string)kk);
      verifik = game.checkWiner(kk);
      writeln(verifik);
      if (verifik)
      {
         foreach (clientss; connectedClients)
         {
            clientss.send("ganhou");
            clientss.close();
         }
         listener.close();
         break;
      }
      else
      {
         writeln("xxxx");
         connectedClients[mestre].send("0");

         connectedClients[mestre].receive(aleatorio);
         sendToAll(connectedClients,cast(string)aleatorio);
      }

      if (id < ((connectedClients.length) - 1))
      {
         id++;
      }
      else
      {
         id = 1;
      }
      pergunta.destroy();
      kk.destroy();
   }

}
