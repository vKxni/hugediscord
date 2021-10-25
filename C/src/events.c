#include <crow/events.h>
#include <crow/log.h>

void dispatch(client_t *bot, json_object *data) 
{

    json_object *t;
    json_object_object_get_ex(data, "t", &t);

	json_object *s;
	json_object_object_get_ex(data, "s", &s);

	bot->seq = json_object_get_int(s);
	json_object_put(s);

    log_debug("Got new event \"%s\"\n", json_object_get_string(t));

    if (strcmp(json_object_get_string(t), "READY") == 0) 
    {
		json_object *_d;

		json_object_object_get_ex(data, "d", &_d);

        log_debug(json_object_get_string(_d));

        json_object *session_id;
        json_object_object_get_ex(_d, "session_id", &session_id);

        bot->session_id = json_object_get_string(session_id);

        log_debug("Session id: %s", bot->session_id);

		json_object *output_user;
		json_object_object_get_ex(_d, "user", &output_user);
        bot->self = user(output_user);

		json_object_put(_d);

        if (!bot->on_ready) 
        {
            return;
        }

        bot->on_ready(bot);
    }
    
    if (strcmp(json_object_get_string(t), "MESSAGE_CREATE") == 0) 
    {
        json_object *output; 
		json_object_object_get_ex(data, "d", &output);

        message_t msg = message(output);

        if (!bot->on_message) 
        {
            log_debug("on_message handler is not set!");
            return;
        }

        bot->on_message(bot, msg);
    }

}