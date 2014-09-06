#include <SPI.h>
#include <IRremote.h>
#include <RCSwitch.h>
#include <HttpClient.h>
#include <Ethernet.h>
#include <EthernetClient.h>

byte MAC[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
int STATUS_PIN = 4;

RCSwitch mySwitch = RCSwitch();
IRsend irsend;

const char kHostname[] = "homeauto.dewar.co.nz"; //"192.168.20.102.xip.io";
const char kPath[] = "/get?devices=H,S&long=1";

// Number of milliseconds to wait without receiving any data before we give up
const int kNetworkTimeout = 30*1000;
// Number of milliseconds to wait if no data is available before trying again
const int kNetworkDelay = 1000;

unsigned long WATTS_CLEVER_DEVICE_ID = 0x62E650;
unsigned char ON_CODES[3] = {0xE,0xC,0xA};
unsigned char OFF_CODES[3] = {0x6, 0x4, 0x2};

void setup()
{
  Serial.begin(9600); 

  while (Ethernet.begin(MAC) != 1)
  {
    Serial.println("Error getting IP address via DHCP, trying again...");
    delay(15000);
  }
  
  pinMode(STATUS_PIN, OUTPUT);
  pinMode(7, OUTPUT);
  mySwitch.enableTransmit(7);
  Serial.println("Ready");
}

void loop()
{
  int response = 0;
  
  EthernetClient c;
  HttpClient http(c);
  
  response = http.get(kHostname, kPath);
  if (response == 0)
  {
    Serial.println("startedRequest ok");

    response = http.responseStatusCode();
    if (response >= 0)
    {
      Serial.print("Got status code: ");
      Serial.println(response);

      if(response == 204){
        //Serial.println("Continuing...");
        return;
      }
      else if(response != 200){
        //Serial.println("Continuing after delay..."); 
        delay(10000);
        return;
      }

      response = http.skipResponseHeaders();
      if (response >= 0)
      {
        int bodyLen = http.contentLength();
        //Serial.print("Content length is: ");
        Serial.println(bodyLen);
        Serial.println();
        //Serial.println("Body returned follows:");
      
        // Now we've got to the body, so we can print it out
        unsigned long timeoutStart = millis();
        char data[bodyLen];
        int i = 0;
        // Whilst we haven't timed out & haven't reached the end of the body
        while ( (http.connected() || http.available()) && i < bodyLen &&
               ((millis() - timeoutStart) < kNetworkTimeout) )
        {
            if (http.available())
            {
                char c = http.read();
                // Print out this character
                Serial.print(c);
                data[i++] = c;
               
                // We read something, reset the timeout counter
                timeoutStart = millis();
            }
            else
            {
                // We haven't got any data, so let's pause to allow some to
                // arrive
                delay(kNetworkDelay);
            }
        }
        
        if(i != bodyLen){
          //Serial.print("Failed to retrieve all data. Got ");
          Serial.print(i);
          Serial.print(" bytes");
          delay(10000);
          return;
        }
        
        execute(data, bodyLen);
      }
      else
      {
        //Serial.print("Failed to skip response headers: ");
        Serial.println(response);
        delay(10000);
      }
    }
    else
    {    
      //Serial.print("Getting response failed: ");
      Serial.println(response);
      delay(10000);
    }
  }
  else
  {
    Serial.print("Connect failed: ");
    Serial.println(response);
    delay(10000);
  }
  http.stop();
}

byte getVal(char c)
{
   if(c >= '0' && c <= '9')
     return (byte)(c - '0');
   else
     return (byte)(c-'A'+10);
}

void execute(char data[], int len){
  //char data[] = {d1,d2,d3};
  char device = data[0];
  if(device == 'I'){
      Serial.print("Infrared TX: ");
      
      char protocol = data[1];
      if(protocol == 'F'){
        Serial.print("Fujitsu [");
        // Copy data
        int dataLen = (len - 2) / 2;
        unsigned char irData[dataLen];
        for(int i=0; i<dataLen; i++){
          //irData[i] = data[i+2];
          irData[i] = getVal(data[i*2+2+1]) + (getVal(data[i*2+2]) << 4);
          Serial.print(irData[i], HEX);
        }
        digitalWrite(STATUS_PIN, HIGH);
        Serial.print(dataLen*8, DEC);
        irsend.sendFujitsu(irData, dataLen * 8);
        digitalWrite(STATUS_PIN, LOW);
        Serial.println("]");
      }
      else{
        Serial.print("Unknown Protocol '" + protocol);
        Serial.println("']");
        return;
      }
      
      
    }
    
    else if(device == 'S'){
      Serial.print("Switch: ");
      char subDevice = data[1];
      char index = subDevice - '0';
      if(index < 0 || index > 2){
        Serial.println("Bad sub-device"); 
      }
      else{
        Serial.print('#');
        Serial.print(index, DEC);
        Serial.print(' ');
        char command = data[2];
        if(command == '0'){
          Serial.println("OFF"); 
          long code = WATTS_CLEVER_DEVICE_ID + OFF_CODES[index];
          Serial.println(code, HEX);
          Serial.println(code, DEC);
          mySwitch.send(code, 24);
        }
        else if(command == '1'){
          Serial.println("ON");
          Serial.println(WATTS_CLEVER_DEVICE_ID + ON_CODES[index], HEX);
          mySwitch.send(WATTS_CLEVER_DEVICE_ID + ON_CODES[index], 24);
        }
        else{
          Serial.println("Unrecognized command");
        }
      }
    }
    else{
      //Serial.println("Normal send");
       //irsend.sendFujitsu(ON_20_DEG_HEAT, 128);
    }
    
}
