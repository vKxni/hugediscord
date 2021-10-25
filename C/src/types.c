#include <crow/types.h>
#include <crow/log.h>

#include <json-c/json.h>

user_t user(json_object *raw) 
{
    user_t u;

    json_object *id;
    json_object_object_get_ex(raw, "id", &id);
    u.id = json_object_get_string(id);

    json_object *username;
    json_object_object_get_ex(raw, "username", &username);
    u.username = json_object_get_string(username);

    json_object *discriminator;
    json_object_object_get_ex(raw, "discriminator", &discriminator);
    u.discriminator = json_object_get_string(discriminator);

    json_object *avatar;
    json_object_object_get_ex(raw, "avatar", &avatar);
    u.avatar = json_object_get_string(avatar);

    json_object *bot;
    json_object_object_get_ex(raw, "bot", &bot);
    u.bot = json_object_get_int(bot);

    json_object *mfa_enabled;
    json_object_object_get_ex(raw, "mfa_enabled", &mfa_enabled);
    u.mfa_enabled = json_object_get_int(mfa_enabled);

    json_object *verified;
    json_object_object_get_ex(raw, "verified", &verified);
    u.verified = json_object_get_int(verified);

    json_object *email;
    json_object_object_get_ex(raw, "email", &email);
    u.email = json_object_get_string(email);

    return u;
}

message_t message(json_object *raw) 
{
    message_t msg;

    msg.id = json_object_get_string(json_object_object_get(raw, "id"));
    msg.author = user(json_object_object_get(raw, "author"));
    msg.channel_id = json_object_get_string(json_object_object_get(raw, "channel_id"));
    msg.timestamp = json_object_get_string(json_object_object_get(raw, "timestamp"));
    msg.edited_timestamp = json_object_get_string(json_object_object_get(raw, "edited_timestamp"));
    msg.tts = json_object_get_int(json_object_object_get(raw, "tts"));
    msg.mention_everyone = json_object_get_int(json_object_object_get(raw, "mention_everyone"));
    msg.pinned = json_object_get_int(json_object_object_get(raw, "pinned"));
    msg.webhook_id = json_object_get_string(json_object_object_get(raw, "webhook_id"));
    msg.content = json_object_get_string(json_object_object_get(raw, "content"));

    return msg;
}