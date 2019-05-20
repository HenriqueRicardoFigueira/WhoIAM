module app;
import std.socket, std.stdio;

final class Player
{
	string name;
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

}

final class Master{
    
    char[] resposta;
    
    void setResposta()
    {
        writeln("Você é o Mestre");
        writeln("Digite a resposta certa para o jogo:");
        readln(resposta);
    }
    
    char[] getResposta()
    {
        return resposta;
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



void manageGame(Socket socket, Player p1)
{
    char[200] buffer;
    char[200] bea;
    bool seila = true;
    writeln("player entrou");
    char[] resposta;
    auto resp = buffer[0 .. socket.receive(buffer)];
    if(p1.getMaster){
        while(true)
        {
            //resposta = '       ';
            
            if(socket.receive(resp)){
                socket.receive(resp);
                writeln(resp);
                writeln("Responda sim ou nao: ");
                resp = new char[200];
                readln(resposta);
                socket.send(resposta);
                resposta = new char[200];
            }
        }
    }
    else{
        while (true)
        {
            humus:
            write("1. Faca uma pergunta ",p1.getName);
            writeln(" ");
            write("2.");
            readln(resposta);
            if(resposta.length > 2){
                socket.send(resposta);
            }
            else{
                goto humus;
            }
            resposta = new char[200];
            bea = new char[200];
            if(socket.receive(bea)){
                socket.receive(bea);
                writeln(bea);

                bea = new char[200];
            }
        }
    }

    }



void getChat(Socket socket, Player p1){
    char[1024] buffer;
    char[1024] tempbuffer;
    writeln("Aaaa getchat");
    char[] pergunta;
    tempbuffer = buffer[0 .. socket.receive(buffer)];

    while(true){

        if (tempbuffer != buffer){
            tempbuffer = buffer[0 .. socket.receive(buffer)];
            auto x = buffer[0 .. socket.receive(buffer)];
            writeln(x);
            if(x == p1.getName()){
                writeln("Faca uma pergunta ou uma tentativa");
                readln(pergunta);
                socket.send(pergunta);
            }else{
                writeln("Ainda nao eh sua vez");
            }  
        }
 
    }
}

void main() {
    char[] name;
    auto socket = new Socket(AddressFamily.INET,  SocketType.STREAM);
    char[1024] buffer;
    Master master = new Master;
    socket.connect(new InternetAddress("localhost", 8080));
    auto received = socket.receive(buffer); // wait for the server to say hello
    writeln("Server said: ", buffer[0 .. received]);
    writeln("Digite seu nick: ");
    readln(name);
    socket.send(name);
    Player player = new Player(cast(string)name);
    auto resp = buffer[0 .. socket.receive(buffer)];
    if(resp == "true")
    {
        player.setMaster(true);
        master.setResposta();
        socket.send(master.getResposta());
        manageGame(socket, player);    
    }    
    else{
        manageGame(socket, player);
    }
}
