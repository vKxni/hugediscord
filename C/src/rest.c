#include <crow/rest.h>
#include <crow/log.h>
#include <requests.h>

#define API_ENDPOINT "https://discordapp.com/api"

void
send_message(char* channel_id, char* text) 
{
    req_t req;
	CURL *curl = requests_init(&req);

	json_object *tosend;
	tosend = json_object_new_object();
	json_object_object_add(tosend, "content", json_object_new_string(text));

	char target[1024];
	sprintf(target, "https://discordapp.com/api/channels/%s/messages", channel_id);

    char header[1024];
    sprintf(header, "Authorization: Bot %s", TOKEN);

    char *auth_header[] = { header };

	requests_post_headers(curl, &req, target, json_object_to_json_string(tosend), auth_header, sizeof(auth_header)/sizeof(char*));

	if (req.ok) {
        log_debug("Request URL: %s\n", req.url);
        log_debug("Response Code: %lu\n", req.code);
        log_debug("Response Body:\n%s", req.text);
	}

    requests_close(&req);
}

guild_channel_t
get_channel(char* channel_id) 
{
	req_t req;
	CURL *curl = requests_init(&req);

    char target[1024];

	sprintf(target, "https://discordapp.com/api/channels/%s", channel_id);

    char header[1024];
    sprintf(header, "Authorization: Bot %s", TOKEN);

    char *auth_header[] = { header };

	requests_get_headers(curl, &req, target, auth_header, sizeof(auth_header)/sizeof(char*));

    if (!req.ok) {
        log_debug("get_channel: something went wrong!");
        return;
    }

    guild_channel_t channel;

    json_object *output;

    output = json_tokener_parse(req.text);

    channel.guild_id = json_object_get_string(json_object_object_get(output, "guild_id"));
    channel.name = json_object_get_string(json_object_object_get(output, "name"));
    channel.id = json_object_get_string(json_object_object_get(output, "id"));
    if (!strcmp(json_object_get_string(json_object_object_get(output, "type")), "text"))
        channel.type = 0;
    else
        channel.type = 1;

    channel.position = json_object_get_int(json_object_object_get(output, "position"));

    //channel.is_private = json_object_get_bool(json_object_object_get(output, "is_private"));

    channel.topic = json_object_get_string(json_object_object_get(output, "topic"));

    channel.last_message_id = json_object_get_string(json_object_object_get(output, "last_message_id"));

    if (channel.type = 1) {
        channel.bitrate = json_object_get_int(json_object_object_get(output, "bitrate"));
        channel.bitrate = json_object_get_int(json_object_object_get(output, "user_limit"));
    }

    requests_close(&req);

    return channel;
}

void
add_reaction(char* channel_id, char *message_id, char *emoji) 
{
	req_t req;
	CURL *curl = requests_init(&req);

	char target[1024];

    char header[1024];
    sprintf(header, "Authorization: Bot %s", TOKEN);

    char *auth_header[] = { header };

	sprintf(target, "https://discordapp.com/api/channels/%s/messages/%s/reactions/%s/@me",channel_id, message_id, emoji);

    requests_put_headers(curl, &req, target, NULL, auth_header, sizeof(auth_header)/sizeof(char*));

    log_debug("Request URL: %s\n", req.url);
    log_debug("Response Code: %lu\n", req.code);
    log_debug("Response Body:\n%s", req.text);

    requests_close(&req);
}

// void
// delete_own_reaction(char* channel_id, char *message_id, char *emoji) {
// 	CURLcode res;

// 	char target[1024];

// 	snprintf(target, sizeof(target), "https://discordapp.com/api/channels/%s/messages/%s/reactions/%s/@me",channel_id, message_id, emoji);

//     curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE");

// 	res = curl_fetch_url(curl, target, cf);

//     long response_code;

//     curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);

//     if (response_code != 204) {
//         if (res != CURLE_OK || cf->size < 1) {
//             fprintf(stderr, "ERROR: Failed to fetch url (%s) - curl said: %s",
//                 target, curl_easy_strerror(res));
//         }
//     }
    
// 	if (cf->payload != NULL) {
// 		log_debug("CURL returned %s", cf->payload);
// 	}
// }