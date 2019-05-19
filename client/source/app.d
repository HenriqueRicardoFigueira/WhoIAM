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
    char[1024] buffer;
    bool seila = true;
    writeln("player entrou");
    auto resp = buffer[0 .. socket.receive(buffer)];
    while(seila)
    {   
        writeln("DIGITE: start");
        //writeln(resp);
        //resp = buffer[0 .. socket.receive(buffer)];
        readln(resp);
        /*
        socket.send(buffer[0 .. socket.receive(buffer)]);
        if(resp == "start")
        {
            resp = null;
            writeln("loop do mestre");
            seila = false;
            //break;
            //goto ali;
            break;
        }
        seila = false;*/
        writeln("loop");
        break;
        

    }
    //auto resp = buffer[0 .. socket.receive(buffer)];
    //ali:
    if (!p1.getMaster){
        char[] pergunta;
        writeln("loop player");
        while(true){
            //readln(resp);

            
            
            if(p1.getName()){
                writeln("Faça uma pergunta ou uma tentativa");
                
                readln(pergunta);

                if(pergunta.length > 1){
                    socket.send(pergunta); 
                }
                //socket.send(pergunta);
            }else{
                writeln("Ainda não é sua vez");
            }  
        }   
    }
    else{

        writeln("loop mestre");
        char[] pergunto;
        char[] acn;
        auto ancora = buffer[0 .. socket.receive(buffer)];
        while (true){
            ancora = null;
            socket.receive(ancora);
        
            write(ancora);
            //auto anc = buffer[0 .. socket.receive(buffer)];
            writeln("responda sim ou nao.");
            readln(pergunto);
            
            if(pergunto == "sim"){
                socket.send("sim");
            }else{
                socket.send("nao");
            }

            while(ancora == acn){
                socket.receive(acn);
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
                writeln("Faça uma pergunta ou uma tentativa");
                readln(pergunta);
                socket.send(pergunta);
            }else{
                writeln("Ainda não é sua vez");
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
