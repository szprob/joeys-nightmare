# Globals.gd
extends Node

# 定义全局常量
# player
const SPEED = 125.0
const JUMP_VELOCITY = -200.0  # 初始跳跃速度
const MAX_JUMP_HOLD_TIME = 0.3  # 玩家按住跳跃键的最大时间
const MAX_JUMP_VELOCITY = -350.0  # 最大跳跃速度（跳得越高，Y值越小）
const JUMP_BUFFER_TIME = 0.15  # 跳跃缓冲时间，0.3秒
const DROP_DOWN_TIME = 0.3  # 掉落的禁用时间
const ONE_WAY_PLATFORM_LAYER =2 
# slime
const SLIME_SPPED = 60
# modules
const FALLING_TRAP_SPEED = 200
const MOVE_PLATFORM_SPEED = 50

# 如果需要，也可以定义全局变量或函数
