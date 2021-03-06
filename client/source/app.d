module app;
import std.socket;
import std.stdio;


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

final class Master
{

    char[] resposta;
    Player master;

    void setResposta()
    {
        writeln("Voce eh o Mestre");
        writeln("Digite a resposta certa para o jogo:");
        readln(resposta);
    }

    char[] getResposta()
    {
        return resposta;
    }

    void setPlayerMaster(Player p1)
    {
        master = p1;
    }

    Player getPlayerMaster()
    {
        return master;
    }

    void masterResponse(Socket socket)
    {
        char[] x;
        faca:
        writeln("Responda Sim ou Nao");
        readln(x);
        char[] resp = x[0 ..  x.length-1];
        if((resp == "sim") || (resp == "SIM") || (resp == "não") || (resp == "NÃO") || (resp == "nao") || (resp == "NAO"))
        {        
            socket.send(resp);
            return;
        }
        else{
            goto faca;
        }
    }

}

bool checaComandos(string palavra)
{
    string[] comandos = ["HELP", "RULES", "TALKTOME", "QUIT", "/help", "/quit", "You are"];

    //string novaparlabra = text(palavra[0 .. tam]);

    //funcao que checa se eh uma palavra reservada
    auto tamo = comandos.length;
    int i = 0;
    for (i = 0; i < tamo; i++)
    {
        if (comandos[i] == palavra)
        {
            if ("HELP" == palavra)
            {
                string a = "> Para sair > QUIT | /quit \n> Para saber as regras >  RULES | /rules \n";
                writeln(a);
                return true;
            }
            else if ("RULES" == palavra)
            {
                string b = "> A regras sao simples: \n> Um fala de cada vez \n> Sempre que um player pergunta, eh vez do mestre responder \n> O mestre soh pode responder 'sim' ou 'nao' \n> Ganha quem acertar primeiro o personagem que o mestre eh \n> O mestre que comanda a sala e avisa quem ganha com o comando (GANHADOR player)";
                writeln(b);
                return true;
            }
        }
    }
    return false;
}

void startGame(Socket socket, Player p1, Master master)
{
    char[1024] buffer;
    bool control = true;

    while (control)
    {
        auto resp = buffer[0 .. socket.receive(buffer)];
        if (resp == "start")
        {
            break;
        }
    }
    waitResp(socket, p1, master);
}

void waitResp(Socket socket, Player p2, Master master)
{

    char[50] buffer;
    char[] respServer;
    char[50] respMestre;
    char[] pergunta;
    //auto x = buffer[0 .. socket.receive(buffer)];
    while (true)
    {
        auto x = buffer[0 .. socket.receive(buffer)]; 
        if (x == "1")
        {
            writeln("Faca uma pergunta ou uma tentativa");
            readln(pergunta);

            
            socket.send(pergunta);
            writefln(buffer[0 .. socket.receive(buffer)]);
            if ((buffer[0 .. socket.receive(buffer)]) == "3")
            {
                writeln("Voce ganhou");
                p2.setScore();
                
                socket.close();
                return;
            }
            else
            {
                writeln(buffer);
                writeln("voce perdeu a vez");

            }
        }

        else if ((x == "0") && (p2.getMaster()))
        {   
            if(x == null)
            {
                writeln("Player acertou");
                socket.close();
                return;
            }
            
            master.masterResponse(socket);

        }
        
        else if (x == null)
        {
                writeln("Voce perdeu");
                socket.close();
                return;
        }
        else if(x != "3"){
            writeln(x);
        }
        
        buffer.destroy();
    }


}

//Master master = new Master();
void main()
{
    char[] name;
    auto socket = new Socket(AddressFamily.INET, SocketType.STREAM);
    char[1024] buffer;
    socket.connect(new InternetAddress("localhost", 8080));
    auto received = socket.receive(buffer); // wait for the server to say hello
    writeln("Server said: ", buffer[0 .. received]);
    nick:
    writeln("Digite seu nick: ");
    readln(name);
    if(name.length >= 2)
        socket.send(name);
    else{
        writeln("nome invalido");
        goto nick;
    }

    Master master = new Master;
    Player player = new Player(cast(string) name);
    auto resp = buffer[0 .. socket.receive(buffer)];
    if (resp == "true")
    {
        player.setMaster(true);
        master.setResposta();
        master.setPlayerMaster(player);
        socket.send(master.getResposta());
        startGame(socket, player, master);
    }
    else
    {
        startGame(socket, player, master);
    }
}
