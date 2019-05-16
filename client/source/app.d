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

void main() {
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
    foreach(line; stdin.byLine) {
       socket.send(line);
       writeln("Server said: ", buffer[0 .. socket.receive(buffer)]);
    }
}
