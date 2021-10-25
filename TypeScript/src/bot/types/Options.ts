import { PermissionString, Message } from 'discord.js';

export interface CommandOptions {
  name: string,
  aliases?: string[],
  description: string,
  usage?: string,
  category?: string,
  cooldown?: number,
  ownerOnly?: boolean,
  guildOnly?: boolean,
  requiredArgs?: number,
  userPermissions?: PermissionString[],
  clientPermissions?: PermissionString[],
  exec: (msg: Message, args: string[]) => unknown | Promise<unknown>,
};

export type CommandType = Omit<CommandOptions, 'exec'>;

export interface EventOptions {
  name: string,
  once?: boolean,
};