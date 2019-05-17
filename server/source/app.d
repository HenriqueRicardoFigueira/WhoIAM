module app;
import std.socket;
import std.stdio;
import std.conv : text;
import std.string;
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

}



class palavrasChaves
{
	string persona;
	string[] comandos = ["HELP", "TALKTOME", "QUIT", "/help", "/quit", "You are"];

	void setPersona(string palavra)
	{
		//inicializa a classe setando a persona
		this.persona = palavra;
	}

	bool checaComandos(string palavra)
	{


      //string novaparlabra = text(palavra[0 .. tam]);
  
		//função que checa se é uma palavra reservada
		auto tamo = comandos.length;
		int i = 0;
		for (i = 0; i < tamo; i++)
		{
			if (comandos[i] == palavra)
			{
				return 1;
			}
		}
		return 0;
	}

	void comandoQuit()
	{
		//render!("index.dt");
      return;
	}

	string comandoHelp()
	{
		string a = "> Para sair > QUIT | /quit \n				
					> Para saber as regras >  RULES | /rules \n";
		return a;
	}
	string comandoRules()
	{
		string a = "> A regras são simples: \n				
					> Um fala de cada vez \n				
					> Sempre que um player pergunta, é vez do mestre responder \n				
					> O mestre só pode responder 'sim' ou 'nao' \n				
					> Ganha quem acertar primeiro o personagem que o mestre é \n				
					> O mestre que comanda a sala e avisa quem ganha com o comando (GANHADOR player)";				
		return a;
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
   
   //palavrasChaves palavrasChave;
   while (isRunning)
   {
      readSet.reset();
      readSet.add(listener);
      foreach (client; connectedClients)
         readSet.add(client);
      if (Socket.select(readSet, null, null))//conexao e config mestre
      {
         foreach (client; connectedClients)
            if (readSet.isSet(client))// Se cliente, fala
            {
               // read from it and echo it back
               auto got = client.receive(buffer);


               writeln (got, "TAMANHIM");


               //bool isreserved = false;
               //string copy = cast(string)buffer[0 .. buffer.length];
               //writeln (copy);

               //isreserved = palavrasChave.checaComandos( copy);
               //writeln (isreserved);

               
               
               client.send(buffer[0 .. got]);
            }
         if (readSet.isSet(listener))
         {
            // the listener is ready to read, that means
            // a new client wants to connect. We accept it here.
            auto newSocket = listener.accept();
            newSocket.send("Hello!\n"); // say hello
            connectedClients ~= newSocket; // add to our list
           
            Player p1 = new Player(cast(string)buffer[0 .. newSocket.receive(buffer)]);
            if (connectedClients.length == 1)
            {
               p1.setMaster(true);
               p1.setIp(newSocket.hostName());
               game.setPlayer(p1);
               game.setMaster(p1.getName());
            }
            else{
               game.setPlayer(p1);
               p1.setIp(newSocket.remoteAddress().toAddrString());
            }
            Player[] x = game.getPlayers();
            foreach(px; x)
            {
               writeln(px.getName());
               writeln(px.getMaster());
               writeln(px.getIp());
            }
         }
      }
   }
}
