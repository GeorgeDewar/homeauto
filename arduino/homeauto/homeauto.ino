#include <SPI.h>
#include <IRremote.h>
#include <RCSwitch.h>
#include <HttpClient.h>
#include <Ethernet.h>
#include <EthernetClient.h>

byte MAC[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
int STATUS_PIN = 4;
int RF_TX_PIN  = 7;

RCSwitch mySwitch = RCSwitch();
IRsend irsend;

const char kHostname[] = "homeauto.dewar.co.nz"; //"192.168.20.102.xip.io";
const char kPath[] = "/get?devices=H,S&long=1";

// Number of milliseconds to wait without receiving any data before we give up
const int kNetworkTimeout = 30*1000;
// Number of milliseconds to wait if no data is available before trying again
const int kNetworkDelay = 1000;

void setup()
{
  Serial.begin(9600); 

  while (Ethernet.begin(MAC) != 1)
  {
    Serial.println(F("DHCP failed, retry..."));
    delay(15000);
  }
  
  pinMode(STATUS_PIN, OUTPUT);
  pinMode(RF_TX_PIN, OUTPUT);
  mySwitch.enableTransmit(RF_TX_PIN);
  Serial.println(F("Ready"));
}

void loop()
{
  int response = 0;
  
  EthernetClient c;
  HttpClient http(c);
  
  response = http.get(kHostname, kPath);
  if (response == 0)
  {
    Serial.println(F("\nStarted Request"));

    response = http.responseStatusCode();
    if (response >= 0)
    {
      Serial.print(F("Status: "));
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
        Serial.print(F("Content length: "));
        Serial.print(bodyLen);
        Serial.println(F(" bytes"));
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
          Serial.print(F("Failed to retrieve all data. Got "));
          Serial.print(i);
          Serial.print(F(" bytes"));
          delay(10000);
          return;
        }
        
        Serial.println();
        execute(data, bodyLen);
      }
      else
      {
        Serial.print(F("Failed to skip response headers: "));
        Serial.println(response);
        delay(10000);
      }
    }
    else
    {    
      Serial.print(F("Getting response failed: "));
      Serial.println(response);
      delay(10000);
    }
  }
  else
  {
    Serial.print(F("Connect failed: "));
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
      Serial.print(F("Infrared TX: "));
      
      char protocol = data[1];
      if(protocol == 'F'){
        Serial.print(F("Fujitsu ["));
        // Copy data
        int dataLen = (len - 2) / 2;
        unsigned char irData[dataLen];
        for(int i=0; i<dataLen; i++){
          irData[i] = getVal(data[i*2+2+1]) + (getVal(data[i*2+2]) << 4);
          Serial.print(irData[i], HEX);
        }
        digitalWrite(STATUS_PIN, HIGH);
        Serial.print(dataLen*8, DEC);
        irsend.sendFujitsu(irData, dataLen * 8);
        digitalWrite(STATUS_PIN, LOW);
        Serial.println(F("]"));
      }
      else{
        Serial.print(F("Unknown Protocol '"));
        Serial.print(protocol);
        Serial.println(F("'"));
        return;
      }
      
      
    }
    
    else if(device == 'R'){
      Serial.print(F("RF Switch TX: "));
      char subDevice = data[1];
      if(subDevice == 'S'){
        int bits = (len - 2) * 4;

        // All this to get it null-terminated
        char msg[(len - 2) + 1];
        for(int i=0; i<len-2; i++){
          msg[i] = data[i+2]; 
        }      
        msg[len-2] = '\0';

        unsigned long value = strtoul(msg, 0, 16);
        Serial.print(value, HEX);
        digitalWrite(STATUS_PIN, HIGH);
        mySwitch.send(value, bits); 
        digitalWrite(STATUS_PIN, LOW);
        Serial.println();
      }
      else{
        Serial.print(F("Unrecognised RF protocol: '"));
        Serial.print(subDevice);
        Serial.println(F("'"));
      }
    }
    else{
      Serial.print(F("Unrecognised device: '"));
      Serial.print(device);
      Serial.println(F("'"));
    }
    
}
