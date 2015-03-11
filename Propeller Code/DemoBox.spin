{Runs our new demo box at the Arkansas regionsal}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000


        PP_RX      = 31  'receive from propplug 
        PP_TX      = 30  'trasmit to propplug
        EEPROM_SDA = 29
        EEPROM_SCL = 28
        

        LCD_Pin    = 15
        LCD_Baud   = 19_200

        ADC_CS     = 23
        ADC_DI     = 22
        ADC_DO     = 21
        ADC_CLK    = 20

        GPIO0      = 4
        GPIO1      = 5
        GPIO2      = 6
        GPIO3      = 7

        RRIO_TX    = 19   'so RX on propeller
        RRIO_RX    = 8
                              
        PROP_RRIO_TX = RRIO_RX     'TX from propeller to roborio
        PROP_RRIO_RX = RRIO_TX     'RX to propeller from roborio
        
        RRIO_CS    = 9
        RRIO_CLK   = 10
        RRIO_MISO  = 11
        RRIO_MOSI  = 12
        RRIO_SCL   = 13
        RRIO_SDA   = 14
        
        SD_D2      = 0
        SD_D3      = 27
        SD_CMD     = 3
        SD_CLK     = 2
        SD_D0      = 1
        SD_D1      = 0
        SD_SWTICH  = 24
        SD_DETECT  = 26
              
        SD_CS      = SD_D3
        SD_DI      = SD_CMD
        SD_SCLK    = SD_CLK
        SD_DO      = SD_D0
                       
        LED_GREEN  = 18
        LED_YELLOW = 17
        LED_RED    = 16

        Neo_Pin    = GPIO0
        Neo_Length = 60
        NUMCHANNELS = 5

        batt_loc   = $A8 + 11
        led_loc    = $BC + 13
VAR
  'stack space            
  long neostack[1000]
  long serstack[1000]

  'LED's:
  long colors[6], colors2[12]
  byte brightness         
  long RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, BLACK, WHITE
  long HUSKIEORANGE, HUSKIEBLUE
  byte channels[NUMCHANNELS]
  byte ch
  
  'Serial
  long buttonPressed_
  byte battV[7]
  byte neoCurrent[7]
OBJ
  lcd           : "serial_lcd"
  adc           : "ADC driver"
  neo           : "Neopixel Driver"   
  rand          : "RealRandom"
  ser           : "FullDuplexSerial"
PUB init
  lcd.init(LCD_Pin,LCD_Baud,4)
  adc.start2pin(ADC_DI, ADC_DO, ADC_CLK, ADC_CS,$00FF)
  neo.start(Neo_Pin,Neo_Length)
  brightness:=100
  setcolors
  cognew(Neopixels, @neostack)

  buttonPressed_:=false    
  battV[6]:=0                
  neoCurrent[6]:=0
  ser.start(PROP_RRIO_RX, PROP_RRIO_TX, 0, 115200)
  cognew(SerialConnection, @serstack)
  repeat
    LCD_Main
  
PUB LCD_Main
  lcd.cls
  waitcnt(cnt+clkfreq/10)
  lcd.backlight(true)
  lcd.cursor(0)
  lcd.home
  lcd.str(string("-----TEAM  3061-----"))'set top line
  lcd.str(string(lcd#LCD_LINE1,"  HUSKIE ROBOTICS!"))
  lcd.str(string(lcd#LCD_LINE2,"Battery V: "))
  'lcd.str(string(lcd#LCD_LINE3,"LED Current: "))
  waitcnt(cnt+clkfreq/1000)
  repeat                                                                  
    repeat 5          
      LCD_Write_Vals  
    lcd.putc(lcd#LCD_LINE0) 
    lcd.str(string("     TEAM  3061     "))'blink top line
    repeat 5          
      LCD_Write_Vals     
    lcd.putc(lcd#LCD_LINE0) 
    lcd.str(string("-----TEAM  3061-----"))'set top line  
{
-----TEAM  3061-----
  HUSKIE ROBOTICS!
Battery V: xx.xxx
LED Current: xx.xxx 
}

PRI LCD_Write_Vals                     
  lcd.gotoxy(11,2)         
  lcd.str(@battV)                       
  'lcd.gotoxy(13,3)         
  'lcd.str(@neoCurrent)      
  lcd.home
  waitcnt(cnt+clkfreq/10)
PUB SerialConnection  | cmd, channel, x
  repeat
    repeat until ser.rx == $FF ' wait until $FF byte is sent. It represents start of loop.
                                'Used to keep in sync since checksums are not implemented
    cmd := ser.rx
    if cmd == "A" 'button was pressed
      buttonPressed_ := true
    if cmd == "V" 'next 6 bytes, will show battery voltage as string
      repeat x from 0 to 4 'get battery voltage bytes
        battV[x] := ser.rx
      battV[5] := "V"
      ser.rx  
    if cmd == "I" 'current, next byte will show which current channel by use.
      channel := ser.rx
      if channel == "N" ' neopixel channel  
        repeat x from 0 to 4
          neoCurrent[x] := ser.rx
    
                       

PUB Neopixels
  'neo.fill(0,64,neo.color(255,255,255))
  
  repeat          
     gradient
     bounce  
     stripes
     rainbow
     'random  
     center
     stripes

PRI potentiometer
  return 5000
PRI buttonPressed
  if buttonPressed_
    buttonPressed_ := false
    return true
  return false

PRI shade  | c,count
  c := 0
  repeat count from 0 to 20
    neo.fill(0,64,colors2[c])
    c++
    if c > 11
      c := 0
    waitcnt(cnt+clkfreq/2)
    if buttonPressed
      return
    
PRI gradient | r,g,b,freq , count
  freq := potentiometer/50
  'repeat count from 0 to 1
    r := 255
    g := 0
    b := 0
    repeat g from 0 to 255
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat r from 255 to 0
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat b from 0 to 255
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat g from 255 to 0
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
       return
    repeat r from 0 to 255
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
    repeat b from 255 to 0
      neo.fill(0,64,neo.colorx(r,g,b,BRIGHTNESS))
      waitcnt(cnt+clkfreq/freq)
      if buttonPressed
        return
PRI stripes | offset, x, i, count
  offset := 0
  repeat count from 0 to 100
    repeat x from 0+offset to 64+offset
      repeat i from 0 to 3
        neo.set(limit(x+i),HUSKIEORANGE)
      repeat i from 4 to 7
        neo.set(limit(x+i),HUSKIEBLUE)
      'neo.fill(limit(x),limit(x+3),ORANGE)
      if buttonPressed
        return
      'neo.fill(limit(x+4),limit(x+7),BLUE)
      x+=7
    offset++
    if offset > 64
      offset := 0
    waitcnt(cnt+clkfreq/(potentiometer/160))
    
PRI limit(i) : val
  if i < 0
    i := 64-i
    return i
  elseif i > 64
    i := i-64
    return i
  return i  
PRI center | c, x
  c := 0
  repeat 15
    repeat x from 0 to 32
      neo.set(x,colors[c])
      neo.set(Neo_Length-x, colors[c])
      if buttonPressed
        return
      waitcnt(cnt+clkfreq/(potentiometer/50))
    c++
    if c == 6
      c := 0
PRI bounce | c,x , count
  c := 0
  repeat count from 0 to 20
    repeat x from 0 to Neo_Length
      neo.set(x,colors[c])
      if c<2
        neo.set(Neo_Length-x, colors[c+4]) 
      else
        neo.set(Neo_Length-x, colors[c-2])
      if buttonPressed
        return
      waitcnt(cnt+clkfreq/(potentiometer/50))
    c++
    if c == 6
      c := 0
PRI rainbow | x, i , count 
  channels[0] := 64
  repeat x from 1 to NUMCHANNELS
    channels[x] := channels[x-1]-12
  repeat count from 0 to 240
    repeat i from 0 to NUMCHANNELS
      ch := channels[i]
      repeat x from ch to ch-11
        if testCh(x)  
          neo.set(x,colors[ch-x])
      channels[i] := ch+1
      if channels[i]-1 > Neo_Length
        channels[i] := 0
    waitcnt(cnt+clkfreq/(potentiometer/160))
    if buttonPressed
      return
PRI random | x, count 
  repeat count from 0 to 10
    repeat x from 0 to 64
      neo.set(x,neo.colorx(rand.random*255,rand.random*255,rand.random*255,BRIGHTNESS))
    waitcnt(cnt+clkfreq/(potentiometer/50))
    if buttonPressed
      return
PRI testCh(channel)
  return (ch =< 64 and ch => 0)
PRI setColors | x , r, g, b, in
  RED := neo.colorx(255,0,0,BRIGHTNESS)
  ORANGE := neo.colorx(255,136,0,BRIGHTNESS)
  YELLOW :=  neo.colorx(255,255,0,BRIGHTNESS)
  GREEN := neo.colorx(0,255,0,BRIGHTNESS)
  BLUE := neo.colorx(0,0,255,BRIGHTNESS)
  PURPLE :=  neo.colorx(187,0,255,BRIGHTNESS)
  BLACK := neo.colorx(0,0,0,BRIGHTNESS)
  WHITE := neo.colorx(255,255,255,BRIGHTNESS)
  HUSKIEORANGE := neo.colorx(230,92,0,BRIGHTNESS)
  HUSKIEBLUE := neo.colorx(6,0,120,BRIGHTNESS)
  colors[0] := RED
  colors[1] := ORANGE
  colors[2] := YELLOW
  colors[3] := GREEN
  colors[4] := BLUE
  colors[5] := PURPLE

  colors2[0] := RED
  colors2[1] := neo.colorx(255,85,0,BRIGHTNESS)
  colors2[2] := neo.colorx(255,145,0,BRIGHTNESS)
  colors2[3] := neo.colorx(255,204,0,BRIGHTNESS)
  colors2[4] := neo.colorx(217,255,0,BRIGHTNESS)
  colors2[5] := neo.colorx(140,255,0,BRIGHTNESS)
  colors2[6] := neo.colorx(0,255,17,BRIGHTNESS)
  colors2[7] := neo.colorx(0,255,34,BRIGHTNESS)
  colors2[8] := neo.colorx(0,255,255,BRIGHTNESS)
  colors2[9] := neo.colorx(0,4,255,BRIGHTNESS)
  colors2[10]:= neo.colorx(98,0,255,BRIGHTNESS)
  colors2[11]:= neo.colorx(255,0,221,BRIGHTNESS)
  
DAT
name    byte  "string_data",0        
        