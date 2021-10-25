import { CommandType } from '../types/Options';
import { Message, PermissionString } from 'discord.js';
import Bot from '../client/Client';

abstract class Command {
  public name: string;
  public aliases: string[];
  public description: string;
  public usage: string;
  public category: string;
  public cooldown: number;
  public ownerOnly: boolean;
  public guildOnly: boolean;
  public requiredArgs: number;
  public userPermissions: PermissionString[];
  public clientPermissions: PermissionString[];
  public abstract client: Bot;

  constructor(options: CommandType) {
    this.name = options.name;
    this.aliases = options.aliases ?? [];
    this.description = options.description;
    this.usage = options.usage ?? '';
    this.category = options.category ?? 'Misc';
    this.cooldown = options.cooldown ?? 0;
    this.ownerOnly = options.ownerOnly ?? false;
    this.guildOnly = options.guildOnly ?? false;
    this.requiredArgs = options.requiredArgs ?? 0;
    this.userPermissions = options.userPermissions ?? [];
    this.clientPermissions = options.clientPermissions ?? [];
  }

  public abstract exec(msg: Message, args: string[]): unknown | Promise<unknown>;
}

export default Command;