/*
  Mr. Stabby Client Code
  Mark Tabry <marktabry@gmail.com>
  Max Henstell
*/

#include <Ethernet.h>
#include <Dhcp.h>

#include <string.h>

int stabIn = 2;
int stabOut = 3;
int slashLeft = 4;
int slashRight = 5;
int wristLeft = 6;
int wristRight = 7;

byte mac[] = { 0x42, 0x42, 0x42, 0x42, 0x42, 0x42 };

byte server[] = { 72, 14, 204, 103 }; // Google
boolean ipAcquired = false;

boolean clientConnected = false;
int httpStatusPos = 0;
char callerId[32];

Client client(server, 80);

void setup()
{
  Serial.begin(9600);
  resetCallerId( callerId );
  
  pinMode(stabIn, OUTPUT);
  pinMode(stabOut, OUTPUT);
  pinMode(slashLeft, OUTPUT);
  pinMode(slashRight, OUTPUT);
  pinMode(wristLeft, OUTPUT);
  pinMode(wristRight, OUTPUT);
  
  digitalWrite(stabIn, HIGH);
  digitalWrite(slashLeft, HIGH);
  digitalWrite(wristLeft, HIGH);

  delay(2000);

  digitalWrite(stabIn, LOW);
  digitalWrite(slashLeft, LOW);
 digitalWrite(wristLeft, LOW);
  
  Serial.println("getting ip...");
  int result = Dhcp.beginWithDHCP(mac, 60000, 2000);
  
  if(result == 1)
  {
    ipAcquired = true;
    
    byte buffer[6];
    Serial.println("ip acquired...");
    
//    Dhcp.getMacAddress(buffer);
//    Serial.print("mac address: ");
//    printArray(&Serial, ":", buffer, 6, 16);
    
    Dhcp.getLocalIp(buffer);
    Serial.print("ip address: ");
    printArray(&Serial, ".", buffer, 4, 10);
    
//    Dhcp.getSubnetMask(buffer);
//    Serial.print("subnet mask: ");
//    printArray(&Serial, ".", buffer, 4, 10);
//    
//    Dhcp.getGatewayIp(buffer);
//    Serial.print("gateway ip: ");
//    printArray(&Serial, ".", buffer, 4, 10);
//    
//    Dhcp.getDhcpServerIp(buffer);
//    Serial.print("dhcp server ip: ");
//    printArray(&Serial, ".", buffer, 4, 10);
//    
//    Dhcp.getDnsServerIp(buffer);
//    Serial.print("dns server ip: ");
//    printArray(&Serial, ".", buffer, 4, 10);
    delay(3000);
  }
  else
    Serial.println("unable to acquire ip address...");
}

void printArray(Print *output, char* delimeter, byte* data, int len, int base)
{
  char buf[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  
  for(int i = 0; i < len; i++)
  {
    if(i != 0)
      output->print(delimeter);
      
    output->print(itoa(data[i], buf, base));
  }
  
  output->println();
}

void loop()
{
  if(ipAcquired)
  {
    if (!clientConnected) {
      clientConnected = httpGet( "/getLastStabCommand" );
    }
  
    if (client.available()) {
      char c = client.read();
      if ( !httpStatus( c ) ) {
        httpDisco();
      }
      else {
        processCallerId( callerId, c );
        processStab( callerId, c );
      }
    }
    else if (!client.connected()) {
      httpDisco();  
    }
  }
  else
    spinForever();
}

boolean httpGet( char* url ) {
    if (client.connect()) {
      client.print("GET ");
      client.print(url);
      client.println(" HTTP/1.1");
      client.println("Host: stabbyphone.appspot.com");
      client.println();
      return true;
    } else {
      return false;
    }
}

boolean httpStatus( char c ) {
  static char httpStatus[4];
  if ( httpStatusPos >= 9 && httpStatusPos < 12 ) {
    httpStatus[httpStatusPos-9] = c;
  }
  else if ( httpStatusPos == 12 ) {
    httpStatus[3] = 0;
    if ( strcmp( "200", httpStatus ) != 0 ) {
      return false;
    }
  }
  
  if ( httpStatusPos <= 12 ) { 
    httpStatusPos++;
  }
  
  return true;
}

void processCallerId( char* callerId, char c ) {
  static int i = 1;
  static boolean callerIdNext = false;
  if ( c == '!' ) {
    callerIdNext=false;
    i=1;
  }
  if ( callerIdNext ) {
    callerId[i++]=c;
  }
  if ( c == '$' ) {
    callerIdNext=true;
  }
}

void processStab( char* callerId, char c ) {
  static int orderCount = 0;
  static boolean commandNext = false;
  if ( commandNext ) {
    switch( c ) {
      case '1': // Stab
        sendCallerId( callerId );
        stab();
        break;
      case '2': // Gouge
        sendCallerId( callerId );
        gouge();
        break;
      case '3': // Evicerate
        sendCallerId( callerId );
        slash();
        break;
      case '4': // Slash
        sendCallerId( callerId );
        slash();
        break;
      default:
        commandNext = false;
        httpDisco();
        return;
    }
    httpDisco();
    while( !httpGet("/endStabbing") );
    httpDisco();
    commandNext = false;
  }
  else if ( c == '!') {
    commandNext = true;
  }
}

void sendCallerId( char* callerId ) {
  Serial.println( callerId );
  resetCallerId( callerId );
}

void resetCallerId( char* callerId ) {
  callerId[0]='$';
  for( int i=1; i<32; i++ ) {
    callerId[i]=0;
  }
}

void httpDisco() {
  client.stop();
  clientConnected = false;
  httpStatusPos = 0;
}
void stab()
{
 digitalWrite(stabOut, HIGH);
 delay(1500);
 digitalWrite(stabOut, LOW);
 digitalWrite(stabIn, HIGH);
 delay(1000);
 digitalWrite(stabIn, LOW);

 digitalWrite(stabOut, HIGH);
 delay(1500);
 digitalWrite(stabOut, LOW);
 digitalWrite(stabIn, HIGH);
 delay(1000);
 digitalWrite(stabIn, LOW);

 digitalWrite(stabOut, HIGH);
 delay(1500);
 digitalWrite(stabOut, LOW);
 digitalWrite(stabIn, HIGH);
 delay(2000);
 digitalWrite(stabIn, LOW);
}

void gouge()
{
 digitalWrite(stabOut, HIGH);
 delay(1000);
 digitalWrite(stabOut, LOW);

 digitalWrite(wristLeft, HIGH);
 delay(750);
 digitalWrite(wristLeft, LOW);
 digitalWrite(wristRight, HIGH);
 delay(750);
 digitalWrite(wristRight, LOW);
 digitalWrite(wristLeft, HIGH);
 delay(750);
 digitalWrite(wristLeft, LOW);
 digitalWrite(wristRight, HIGH);
 delay(750);
 digitalWrite(wristRight, LOW);
 digitalWrite(wristLeft, HIGH);
 delay(750);
 digitalWrite(wristLeft, LOW);
 digitalWrite(wristRight, HIGH);
 delay(750);
 digitalWrite(wristRight, LOW);

 digitalWrite(stabIn, HIGH);
 delay(2000);
 digitalWrite(stabIn, LOW);
}

void slash()
{
 digitalWrite(stabOut, HIGH);
 digitalWrite(slashRight, HIGH);
 delay(500);

 digitalWrite(wristRight, HIGH);
 delay(500);
 digitalWrite(wristRight, LOW);
 digitalWrite(wristLeft, HIGH);
 delay(500);
 digitalWrite(wristLeft, LOW);
 digitalWrite(wristRight, HIGH);
 delay(500);
 digitalWrite(wristRight, LOW);
 digitalWrite(wristLeft, HIGH);
 delay(500);
 digitalWrite(wristLeft, LOW);

 digitalWrite(slashRight, LOW);
 digitalWrite(stabOut, LOW);

 digitalWrite(slashLeft, HIGH);

 digitalWrite(wristRight, HIGH);
 delay(500);
 digitalWrite(wristRight, LOW);
 digitalWrite(wristLeft, HIGH);
 delay(500);
 digitalWrite(wristLeft, LOW);
 digitalWrite(wristRight, HIGH);
 delay(500);
 digitalWrite(wristRight, LOW);
 digitalWrite(wristLeft, HIGH);
 delay(500);
 digitalWrite(wristLeft, LOW);

 digitalWrite(slashLeft, LOW);
 digitalWrite(stabIn, HIGH);
 delay(2000);
 digitalWrite(stabIn, LOW);
 
 digitalWrite(stabOut, HIGH);
 delay(1000);
 digitalWrite(stabOut, LOW);
 digitalWrite(stabIn, HIGH);
 delay(2000);
 digitalWrite(stabIn, LOW);
}

void spinForever()
{
  for(;;)
      ;
}
