(ns discord-bot.commands.getonbrd
  (:require [cheshire.core :as json]
            [clj-http.client :as client]
            [discljord.messaging   :as m]
            )
  )

(use '[discord-bot.state :as state])

(defn get-url [query]
  (format "https://sandbox.getonbrd.dev/api/v0/search/jobs?query=%s&per_page=2&expand=[\"company\"]", query)
  )

(defn parse-item [data]
  (let [
        title (get-in data [:attributes :title])
        remote (get-in data [:attributes :remote]) ; boolean
        company (get-in data [:attributes :company :data :attributes :name])
        company-link (get-in data [:attributes :company :data :attributes :web])
        link (get-in data [:links :public_url])
        ]
    (format "
Titulo: %s
Remote: %s
Compañia: %s
Web: %s
Link: %s
---
" title remote company company-link link)
    )
  
  )

(defn get-query [message]
  "Get the query string of the command"
(second (re-matches #"!trabajo (.*)" message))
  )
; @TODO parse/map the data map
(defn get-on-brd-message [query]
  (let [url (get-url query)]
    (let [response (client/get url)]
      (try
        (let [data (:data (json/parse-string (:body response) true))]
          (if (= (count data) 0)
            (format "No se encontraron ofertas de trabajo para: %s" query)
            (let [message (map parse-item data)]
              (format "Encontre esto!
          %s
" (apply str message))
              )
            )
          )
        (catch Exception e (str "exception: " (.getMessage e)))
      )
    )))
  

(defn getonbrd-handler
  [event-type {{bot :bot} :author :keys [channel-id content]}]
  (let [query (get-query content)]
    (when query
    (m/create-message! (:messaging @state/state) channel-id :content (get-on-brd-message query))

    )
  )
)
