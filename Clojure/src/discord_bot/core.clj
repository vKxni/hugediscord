(ns discord-bot.core
  (:require [clojure.edn :as edn]
            [clojure.core.async    :as a]
            [discljord.connections :as c]
            [discljord.messaging   :as m]
            [discljord.events :as e]
            ))
(use '[discord-bot.commands.help :as help])
(use '[discord-bot.commands.getonbrd :as getonbrd])
(use '[discord-bot.state :as state])

(def read-config (edn/read-string (slurp "config.edn")))

(def token (:token read-config))

(def handlers {:message-create [#'help/handler #'getonbrd/getonbrd-handler ]})

(defn -main [& args]                                                       
  (let [event-ch (a/chan 100)                                              
      connection-ch (c/connect-bot! token event-ch)                        
      messaging-ch (m/start-connection! token)                             
      init-state {:connection connection-ch                                
                  :event event-ch                                          
                  :messaging messaging-ch}]                                
  (reset! state/state init-state)                                                
  (try (e/message-pump! event-ch (partial e/dispatch-handlers #'handlers)) 
    (finally                                                               
      (m/stop-connection! messaging-ch)                                    
      (c/disconnect-bot! connection-ch))))                                 
)                                                                          


