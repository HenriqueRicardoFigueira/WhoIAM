module app;
import std.socket;
import std.stdio;
import std.container;
import std.string;
import std.file;


final class Player
{
   string name;
   string ip;
   int score;
   bool master;

   this(string name)
   {
      this.name = name;
      this.score = 0;
   }

   string getName()
   {
      return name;
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
   string master;
   private char[] resposta;

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
      return resposta;
   }

   void setResposta(char[] resp)
   {
      this.resposta = resp;
   }

   bool checkWiner(char[] dica)
   {
      string s = cast(string)dica;
      string resp = cast(string)getResposta();
      if ((s == resp) || (s == toUpper(resp)))
      {
         return true;
      }
      dica.destroy();
      return false;
   }

}

void sendToAll(Socket[] socketlist, string message, int id){
   int cont = 0;
   foreach (clientss; socketlist)
   {
      if(id != cont)
         clientss.send(message);
      cont ++;
   }
}


void sendToAll(Socket[] socketlist, string message){
   foreach (clientss; socketlist)
   {
      clientss.send(message);
   }
}





void gravaPT(string message){
   
   File file = File("score.txt", "w+");
   file.writeln(message);
   file.close();
   
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
   Array!Player players;
   int id = 1;
   int mestre = 0;
   string messageToWrite;
   int msgindex = 0; 
   File file = File("score.txt", "w+");
   file.writeln("Jogo Inicializado!");
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
           
            auto newSocket = listener.accept();
            newSocket.send("Bem vindo ao jogo Who Im !\nAguardando Players...");
            connectedClients ~= newSocket; 

            Player p1 = new Player(cast(string) buffer[0 .. newSocket.receive(buffer)]);
            if (connectedClients.length == 1)
            {
               p1.setMaster(true);
               p1.setIp(newSocket.remoteAddress().toAddrString());
               game.setMaster(p1.getName());
               newSocket.send("true");
               auto x = mestrep[0 .. newSocket.receive(mestrep)];
               game.setResposta(x);
               writeln("resposta do mano");
               writeln(game.getResposta());
               file.write("Resposta do jogo = ");
               file.writeln(game.getResposta());
               file.write("mestre = ");
               file.write(p1.name);
               file.writeln(connectedClients[0].hostName());
               file.writeln();
               msgindex ++;
            }
            else
            {
               p1.setIp(newSocket.remoteAddress().toAddrString());
               newSocket.send("Aguardando Jogadores");
               file.write("player = ");
               file.write(p1.name);
               file.writeln(connectedClients[msgindex].hostName());
               file.writeln();
               msgindex++;
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

  
   char[200] aleatorio;
   bool verifik = false;
   file.writeln("----------------------------------");
   file.writeln("------Partida Comecou!------------");
   file.writeln("----------------------------------");
   msgindex = 1;
   while (true)
   {

      connectedClients[id].send("1");
      auto kk = pergunta[0 .. connectedClients[id].receive(pergunta)];
      file.write("Pergunta num = ");
      file.writeln(msgindex);
      msgindex++;
      sendToAll(connectedClients,cast(string)kk);//ENVIA A PERGUNTA PRA TODOS
      file.writeln(connectedClients[id].hostName());
      file.writeln(kk);
      verifik = game.checkWiner(kk);
      writeln(verifik);
      
      if (verifik)
      {
        
         foreach (clientss; connectedClients)
         {
            clientss.send("3");
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
         file.write("Resposta do Mestre = ");
         file.writeln(cast(string)aleatorio[0 .. 3]);
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
   file.close();
}
