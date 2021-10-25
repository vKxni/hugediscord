open System.Threading.Tasks
open FS.FinkSharp.BotCore

[<EntryPoint>]
let main argv = 
    discord.ConnectAsync() |> Async.AwaitTask |> Async.RunSynchronously
    Task.Delay(-1) |> Async.AwaitTask |> Async.RunSynchronously
    0 // return an integer exit code
