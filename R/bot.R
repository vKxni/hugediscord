if(!("RSelenium" %in% installed.packages())){install.packages("RSelenium");library(RSelenium)}else{library(RSelenium)}

#Startup
rD <- rsDriver(port = 4444L)
remDr <- rD[["client"]]
remDr$navigate("https://discordapp.com/login")

#Login Stuff
LogInBox <- remDr$findElement(using = "xpath", '//*[(@id = "register-email")]')
LogInBox$sendKeysToElement(list('<Email>'))

#Password Stuff
PasswordBox <- remDr$findElement(using = 'xpath', '//*[(@id = "register-password")]')
PasswordBox$sendKeysToElement(list('<Password>'))

#Presses Log in
remDr$findElement(using = 'xpath', '//*[contains(concat( " ", @class, " " ), concat( " ", "btn-primary", " " ))]')$clickElement()

#Opens Anime Society Discord
remDr$findElement(using = 'xpath', '//*[contains(concat( " ", @class, " " ), concat( " ", "guild", " " )) and (((count(preceding-sibling::*) + 1) = 7) and parent::*)]//*[contains(concat( " ", @class, " " ), concat( " ", "avatar-small", " " ))]')$clickElement()

#Code for gettng to channel here
#remDr$findElement(using = 'css', '.channels-wrap')$clickElement()
#channelList <- remDr$findElement(using = 'css', '.channels-wrap')
#channelList$sendKeysToElement(list('k'), key = 'control')

textbox <- remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/form/div/div/textarea')
textbox$sendKeysToElement(list("https://imgur.com/lZF5GO8"))
textbox$sendKeysToElement(list(key="enter"))
textbox$sendKeysToElement(list(key="up_arrow"))
 posted_message <- remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[34]/div[2]/div/div[1]/h2/span[1]')
 posted_message$getElementAttribute("outerHTML")
 posted_message$highlightElement()

xpaths <- c('//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[28]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[29]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[30]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[31]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[32]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[33]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[34]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[35]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[36]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[37]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[38]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[39]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[40]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[41]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[42]/div[2]/div/div[1]/h2/span[1]',
            '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[43]/div[2]/div/div[1]/h2/span[1]')

#get type box
x <- 0
textbox <- remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[3]/div[1]/form/div/div/textarea')
while(x < 50){
  textbox$sendKeysToElement(list("t!fishy"))
  textbox$sendKeysToElement(list(key="enter"))
  Sys.sleep(300)
  #textbox$sendKeysToElement(list("m.nekos"))
  #textbox$sendKeysToElement(list(key="enter"))
  #Sys.sleep(5)
  #textbox$sendKeysToElement(list("t!coin"))
  #textbox$sendKeysToElement(list(key="enter"))
  #Sys.sleep(5)
  #textbox$sendKeysToElement(list("t!numberfacts"))
  #textbox$sendKeysToElement(list(key="enter"))
  #Sys.sleep(5)
  #textbox$sendKeysToElement(list("t!fortune"))
  #textbox$sendKeysToElement(list(key="enter"))
  #Sys.sleep(5)
  #textbox$sendKeysToElement(list("t!8ball Will I fish well>>?"))
  #textbox$sendKeysToElement(list(key="enter"))
  #Sys.sleep(5)
  print(paste("Just printed", x))
  x= x+1
}
while(x < 200){
  textbox$sendKeysToElement(list("Hello Text", key="enter"))  
  Sys.sleep(1.2)
  textbox$sendKeysToElement(list("Ping Pong", key="enter"))
  Sys.sleep(1.2)
  textbox$sendKeysToElement(list(Sys.time(), key="enter"))
  Sys.sleep(1.2)
  x <- x+1
}
remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[3]/div[1]/form/div/div/textarea')$highlightElement()

post_against_shawn <- function(use_path = FALSE, initial_xpath = '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[30]/div[2]/div/div[1]/h2/span[1]', xpatha = '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/div/div/div/div[', xpathb = ']/div[2]/div/div[1]/h2/span[1]', init_token = 20){
  
  xpath1 = xpatha
  xpath2 = xpathb
  token = init_token
  response = "<Picture link or text>"
  is_next = 1
  
  while(TRUE){
    if(is_next==1){
    tryCatch({
      print(paste("Trying to xpath to ", xpatha, token, xpathb, sep = ""))
      textbox <<- remDr$findElement(using = 'xpath', paste(xpatha, token, xpathb, sep = ""))
      textbox$highlightElement()
      token <<- token + 1
      print("    Worked, incrementing token now!")
      },error = function(x){
        tryCatch({
          print("Failed, trying +1 to see if it's a singularity")
          textbox <<- remDr$findElement(using = 'xpath', paste(xpatha, token+1, xpathb, sep = ""))
          token <<- token + 1                           
          },error = function(x){print("error'd again, this is a thing");is_next <<- 2;print("Second")})
      })
    }
    
    #Next should be the message box!
    while(is_next==2)
      {
      tryCatch({
          textbox <<- remDr$findElement(using = 'xpath', paste(xpatha, token-1, xpathb));
          is_next = 3
          print("Third")
        },error = function(x){
          is_next = 1;
          print("Mega error went off")
          Sys.sleep(5)
          token = 10
        })
    }
    
    if(is_next==3){
      html <- textbox$getElementAttribute("outerHTML")
      if(grepl("ayaya|total fucking weeb", html, ignore.case = TRUE)){
        tryCatch({
          post_box <- remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/form/div/div/textarea')
          },error = function(x){post_box <<- remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[3]/div[1]/form/div/div/textarea')
        })
        post_box$sendKeysToElement(list("<Picture link or text>"))
        post_box$sendKeysToElement(list(key="enter"))
      }
        #if(grepl("JiffTheJalapeno", html, ignore.case = TRUE)){
        #  tryCatch({
        #    post_box <- remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[2]/div[1]/form/div/div/textarea')
        #    },error = function(x){post_box <<- remDr$findElement(using = 'xpath', '//*[@id="app-mount"]/div[2]/div[1]/div[2]/div/section/div[3]/div[3]/div[1]/form/div/div/textarea')
        #  })
        #  post_box$sendKeysToElement(list(""))
        #  post_box$sendKeysToElement(list(key="enter"))
        #  
        #}
      is_next = 1
      token = 10
    }
    
  }
}


