import Sword

let bot = Sword(token: "NzExMjcyODgwNTQ0OTQwMTAy.XsAoUQ.bPLlVqs4hAR9qEOOcJNmDBPUlrU")

bot.editStatus(to: "online", playing: "!ss")

bot.on(.messageCreate) { data in
  let msg = data as! Message
//    if msg.author?.isBot ?? false{
//        return
//    }
    switch msg.content{
        
    case "!ss": //Comandos
//        if msg.author?.isBot ?? true{
//            return
//        }
//        else{
        msg.reply(with: """
        Lista de Comandos do Summoners Swift:

        !ss1 - Declaração de variaveis e constantes
        !ss2 - Switch case
        !ss3 - Gráfico
        !ss4 - Fazer um bot no discord
        """)
//        }
        
    case "!ss1": //Variaveis e constantes
        if msg.author?.isBot ?? false{
            return
        }
        else{
        msg.reply(with: """
                        Exemplo:
                        var street: String = "Meu Nome" -> Para modificar o valor durante o código
                        let street: String = "Meu Nome" -> Valor não será alterado

                        -----------------------------------------------------------------------------------------------------

                        Link de referência:
                        https://code.tutsplus.com/pt/tutorials/swift-from-scratch-variables-and-constants--cms-22828

                        """)
        }
        
    case "!ss2": //Switch case
        if msg.author?.isBot ?? false{
            return
        }
        else{
        msg.reply(with: """
                        Exemplo:
                        var str = "algum nome"

                        switch str{
                        case "algum nome":
                            //executa este código
                        
                        case "outro nome":
                            //executa este código

                        default:
                            //caso não achei um caso correspondente executa este código

                        }

                        -----------------------------------------------------------------------------------------------------

                        Link de referência:
                        https://medium.com/ios-os-x-development/switch-cases-in-swift-29366716242d

                        """)
        }
        
    case "!ss3": //Charts
        if msg.author?.isBot ?? false{
            return
        }
        else{
        msg.reply(with: """
                        Links de referência:
                        - Video de gráficos no geral: https://www.youtube.com/watch?v=mWhwe_tLNE8

                        - Gráfico de linha: https://medium.com/@OsianSmith/creating-a-line-chart-in-swift-3-and-ios-10-2f647c95392e

                        - Mudar as labels do X em datas(dificil de entender com erros de variaveis de código): https://stackoverflow.com/questions/41720445/ios-charts-3-0-align-x-labels-dates-with-plots
                        """)
        }
    
    case "!ss4": //bot no discord
        if msg.author?.isBot ?? false{
            return
        }
        else{
        msg.reply(with: """
                        1 - Criar uma aplicação: https://www.techtudo.com.br/dicas-e-tutoriais/2020/01/como-criar-bot-no-discord.ghtml
                        
                        2 - Coloque o bot em um servidor: https://discordapp.com/oauth2/authorize?&client_id=COLOCAR O CLIENTE ID AQUI&scope=bot&permissions=8
                            
                            Achar o client ID: https://www.digitaltrends.com/gaming/how-to-make-a-discord-bot/

                        3 - Baixar API do Sword Swift: https://github.com/Azoy/Sword

                        4 - Seguir o passo a passo para criar um projeto no Xcode e fazer um bot: https://azoy.github.io/Sword
                        """)
        }
    default:
            msg.reply(with: "")
    }
//    else if msg.content == "!ss" {
        
//        var arrayembed = [Embed]()
//        var embed = Embed()
//
//        embed.title = "Titulo"
//
//        arrayembed.append(embed)
//
//        msg.embeds = arrayembed
        
//        msg.reply(with: """
//                        Lista de Comandos:
//
//                        !ss1 - Declaração de variaveis e constantes
//                        !ss2 - Switch case
//                        !ss3 - Gráfico
//                        """)
        
        
    
  }


bot.connect()
