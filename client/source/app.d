module app;
import std.socket, std.stdio;



final class Player
{
	string name;
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

    bool getToken(){
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
}

bool checaComandos(string palavra)
	{
        string[] comandos = ["HELP","RULES", "TALKTOME", "QUIT", "/help", "/quit", "You are"];


      //string novaparlabra = text(palavra[0 .. tam]);
  
		//função que checa se é uma palavra reservada
		auto tamo = comandos.length;
		int i = 0;
		for (i = 0; i < tamo; i++)
		{
			if (comandos[i] == palavra)
			{
                if ("HELP" == palavra){
                    string a = "> Para sair > QUIT | /quit \n> Para saber as regras >  RULES | /rules \n";
		            writeln(a);
                    return true;
                }
                else if("RULES" == palavra){
                    string b = "> A regras sao simples: \n> Um fala de cada vez \n> Sempre que um player pergunta, eh vez do mestre responder \n> O mestre soh pode responder 'sim' ou 'nao' \n> Ganha quem acertar primeiro o personagem que o mestre eh \n> O mestre que comanda a sala e avisa quem ganha com o comando (GANHADOR player)";				
		            writeln(b);
                    return true;
                }
			}
		}
		return false;
	}




void main() {
    //palavrasChaves palavrasChave;
    char[] name;
    auto socket = new Socket(AddressFamily.INET,  SocketType.STREAM);
    char[1024] buffer;
    socket.connect(new InternetAddress("localhost", 2525));
    auto received = socket.receive(buffer); // wait for the server to say hello
    writeln("Server said: ", buffer[0 .. received]);
    writeln("Digite seu nick: ");
    readln(name);
    socket.send(name);
    Player player = new Player(cast(string)name);
    bool x = false;
    foreach(line; stdin.byLine) {
        
        string copy = cast(string)line;

        x = checaComandos(copy[0 .. line.length]);
        writeln(x);
        socket.send(line);

        


        
       writeln("Server said: ", buffer[0 .. socket.receive(buffer)]);
    }
}
