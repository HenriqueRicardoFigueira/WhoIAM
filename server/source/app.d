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
   string resposta;

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

   string getResposta()
   {
      return resposta;
   }

   void setResposta(string resp)
   {
      this.resposta = resp;
   }

   string getPlayersDaVez()
   {
      return playerDaVez;
   }

   void setPlayerDaVez(string name)
   {
      this.playerDaVez = name;
   }

   int returnId(string name)
   {
      int id = 0;
      foreach(Player p1 ; players)
      {
         if(name == p1.name)
            break;
         id++;
      }
      return id;
   }
}

void main()
{

   auto listener = new Socket(AddressFamily.INET, SocketType.STREAM);
   listener.bind(new InternetAddress("localhost", 2525));
   listener.listen(10);
   auto readSet = new SocketSet();
   Socket[] connectedClients;
   char[1024] buffer;
   bool isRunning = true;
   Game game = new Game();
   while (isRunning)
   {
      readSet.reset();
      readSet.add(listener);
      foreach (client; connectedClients)
         readSet.add(client);
      if (Socket.select(readSet, null, null))
      {
         foreach (client; connectedClients)
            if (readSet.isSet(client))
            {
               // read from it and echo it back
               auto got = client.receive(buffer);
               client.send(buffer[0 .. got]);
            }
         if (readSet.isSet(listener))
         {
            // the listener is ready to read, that means
            // a new client wants to connect. We accept it here.
            auto newSocket = listener.accept();
            newSocket.send("Hello mother fuck!\n"); // say hello
            connectedClients ~= newSocket; // add to our list
           
            Player p1 = new Player(cast(string)buffer[0 .. newSocket.receive(buffer)]);
            if (connectedClients.length == 1)
            {
               p1.setMaster(true);
               p1.setIp(newSocket.remoteAddress().toAddrString());
               game.setPlayer(p1);
               game.setMaster(p1.getName());
               newSocket.send("true");
               game.setResposta(cast(string)buffer[0 .. newSocket.receive(buffer)]);
               writeln(game.getResposta());
            }
            else{
               game.setPlayer(p1);
               p1.setIp(newSocket.remoteAddress().toAddrString());
               newSocket.send("Aguardando Jogadores");
            }
         }
      }
   }
}
