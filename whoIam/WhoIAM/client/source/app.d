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

void main() {
    char[] name;
    auto socket = new Socket(AddressFamily.INET,  SocketType.STREAM);
    char[1024] buffer;
    Master master = new Master;
    socket.connect(new InternetAddress("localhost", 2525));
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
    }
    
    else{
        writeln(resp);
    }
}
