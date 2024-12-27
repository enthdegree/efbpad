## Keymap dump
# Observe the host system's key behavior and produces a keymap.h that emulates it.
# Depends on ydotool and showkeys and a lot of things
# Ran in gnome-terminal with shortcuts and F10 menu accelerator disabled

import subprocess
import pickle
import os.path

# Keycode definition
# derived from beginning of: https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
dict_keys = {
    'KEY_RESERVED': 0,
    'KEY_ESC': 1,
    'KEY_1': 2,
    'KEY_2': 3,
    'KEY_3': 4,
    'KEY_4': 5,
    'KEY_5': 6,
    'KEY_6': 7,
    'KEY_7': 8,
    'KEY_8': 9,
    'KEY_9': 10,
    'KEY_0': 11,
    'KEY_MINUS': 12,
    'KEY_EQUAL': 13,
    'KEY_BACKSPACE': 14,
    'KEY_TAB': 15,
    'KEY_Q': 16,
    'KEY_W': 17,
    'KEY_E': 18,
    'KEY_R': 19,
    'KEY_T': 20,
    'KEY_Y': 21,
    'KEY_U': 22,
    'KEY_I': 23,
    'KEY_O': 24,
    'KEY_P': 25,
    'KEY_LEFTBRACE': 26,
    'KEY_RIGHTBRACE': 27,
    'KEY_ENTER': 28,
    'KEY_LEFTCTRL': 29,
    'KEY_A': 30,
    'KEY_S': 31,
    'KEY_D': 32,
    'KEY_F': 33,
    'KEY_G': 34,
    'KEY_H': 35,
    'KEY_J': 36,
    'KEY_K': 37,
    'KEY_L': 38,
    'KEY_SEMICOLON': 39,
    'KEY_APOSTROPHE': 40,
    'KEY_GRAVE': 41,
    'KEY_LEFTSHIFT': 42,
    'KEY_BACKSLASH': 43,
    'KEY_Z': 44,
    'KEY_X': 45,
    'KEY_C': 46,
    'KEY_V': 47,
    'KEY_B': 48,
    'KEY_N': 49,
    'KEY_M': 50,
    'KEY_COMMA': 51,
    'KEY_DOT': 52,
    'KEY_SLASH': 53,
    'KEY_RIGHTSHIFT': 54,
    'KEY_KPASTERISK': 55,
    'KEY_LEFTALT': 56,
    'KEY_SPACE': 57,
    'KEY_CAPSLOCK': 58,
    'KEY_F1': 59,
    'KEY_F2': 60,
    'KEY_F3': 61,
    'KEY_F4': 62,
    'KEY_F5': 63,
    'KEY_F6': 64,
    'KEY_F7': 65,
    'KEY_F8': 66,
    'KEY_F9': 67,
    'KEY_F10': 68,
    'KEY_NUMLOCK': 69,
    'KEY_SCROLLLOCK': 70,
    'KEY_KP7': 71,
    'KEY_KP8': 72,
    'KEY_KP9': 73,
    'KEY_KPMINUS': 74,
    'KEY_KP4': 75,
    'KEY_KP5': 76,
    'KEY_KP6': 77,
    'KEY_KPPLUS': 78,
    'KEY_KP1': 79,
    'KEY_KP2': 80,
    'KEY_KP3': 81,
    'KEY_KP0': 82,
    'KEY_KPDOT': 83,
    'KEY_ZENKAKUHANKAKU': 85,
    'KEY_102ND': 86,
    'KEY_F11': 87,
    'KEY_F12': 88,
    'KEY_RO': 89,
    'KEY_KATAKANA': 90,
    'KEY_HIRAGANA': 91,
    'KEY_HENKAN': 92,
    'KEY_KATAKANAHIRAGANA': 93,
    'KEY_MUHENKAN': 94,
    'KEY_KPJPCOMMA': 95,
    'KEY_KPENTER': 96,
    'KEY_RIGHTCTRL': 97,
    'KEY_KPSLASH': 98,
#    'KEY_SYSRQ': 99,
    'KEY_RIGHTALT': 100,
    'KEY_LINEFEED': 101,
    'KEY_HOME': 102,
    'KEY_UP': 103,
    'KEY_PAGEUP': 104,
    'KEY_LEFT': 105,
    'KEY_RIGHT': 106,
    'KEY_END': 107,
    'KEY_DOWN': 108,
    'KEY_PAGEDOWN': 109,
    'KEY_INSERT': 110,
    'KEY_DELETE': 111,
    'KEY_MACRO': 112,
    'KEY_MUTE': 113,
    'KEY_VOLUMEDOWN': 114,
    'KEY_VOLUMEUP': 115,
#    'KEY_POWER': 116, 
    'KEY_KPEQUAL': 117,
    'KEY_KPPLUSMINUS': 118,
    'KEY_PAUSE': 119,
    'KEY_SCALE': 120,
    'KEY_KPCOMMA': 121,
    'KEY_HANGEUL': 122,
    'KEY_HANJA': 123,
    'KEY_YEN': 124,
    'KEY_LEFTMETA': 125,
    'KEY_RIGHTMETA': 126,
#    'KEY_COMPOSE': 127,
}
dict_keys_inv = {v: k for k, v in dict_keys.items()}
n_keymap_len = max(dict_keys_inv.keys())+1

# Modifier defs
# (actually we don't differentiate between the first member)
dict_mods = {
    'ctrl': ['KEY_LEFTCTRL', 'KEY_RIGHTCTRL'], 
    'shift': ['KEY_LEFTSHIFT', 'KEY_RIGHTSHIFT'], 
    'alt': ['KEY_LEFTALT', 'KEY_RIGHTALT'],
}

# Toggle buttons
dict_toggles = {
    'caps': 'KEY_CAPSLOCK',
}

# Keystroke specs we won't try to read (GNOME or the kernel eats them)
blacklist = [
    ['KEY_F1',['ctrl','alt']], # Kernel Console Emulator
    ['KEY_F2',['ctrl','alt']],
    ['KEY_F3',['ctrl','alt']],
    ['KEY_F4',['ctrl','alt']],
    ['KEY_F5',['ctrl','alt']],
    ['KEY_F6',['ctrl','alt']],
    ['KEY_F7',['ctrl','alt']],
    ['KEY_F8',['ctrl','alt']],
    ['KEY_F9',['ctrl','alt']],
    ['KEY_F10',['ctrl','alt']],
    ['KEY_F11',['ctrl','alt']],
    ['KEY_F12',['ctrl','alt']],
    ['KEY_F2',['alt']], # GNOME keyboard shortcuts
    ['KEY_F4',['alt']],
    ['KEY_F6',['alt']],
    ['KEY_F6',['shift','alt']], 
    ['KEY_F7',['alt']],
    ['KEY_F8',['alt']],
    ['KEY_F10',['alt']],
    ['KEY_SPACE',['alt']],
    ['KEY_ESC',['alt']],
    ['KEY_ESC',['shift','alt']],
    ['KEY_ESC',['ctrl','shift','alt']],
    ['KEY_GRAVE',['alt']],
    ['KEY_GRAVE',['shift','alt']],
    ['KEY_TAB',['alt']],
    ['KEY_TAB',['shift','alt']],
    ['KEY_TAB',['ctrl','alt']],
    ['KEY_TAB',['ctrl','shift','alt']],
    ['KEY_SYSRQ',[]],
    ['KEY_SYSRQ',['ctrl','shift']],
    ['KEY_SYSRQ',['shift']],
    ['KEY_INSERT',['shift']],
    ['KEY_INSERT',['shift','alt']],
    ['KEY_DELETE',['ctrl','alt']],
    ['KEY_R',['ctrl','shift','alt']],
    ['KEY_U',['ctrl','shift']],
    ['KEY_U',['ctrl','shift','alt']],
    ['KEY_LEFT',['ctrl','shift','alt']],
    ['KEY_LEFT',['ctrl','alt']],
    ['KEY_RIGHT',['ctrl','shift','alt']],
    ['KEY_RIGHT',['ctrl','alt']],
    ['KEY_LEFTMETA',[]],
    ['KEY_RIGHTMETA',[]],
]

def get_keydumparg(ks_spec, append_C_d=True):
    # ks_spec[0] = dict_keys entry of key to press
    # ks_spec[1] = list of dict_mods entries, modifiers to press
    # ks_spec[2] = list of dict_toggles entries, toggles to activate
    # returns ksarg as used in get_seq
    key = ks_spec[0]
    key_val = dict_keys[key]
    
    mods = ks_spec[1]
    mod_val = []
    for mod in mods: mod_val.append(dict_keys[dict_mods[mod][0]])

    toggles = ks_spec[2]
    toggle_val = []
    for tog in toggles: toggle_val.append(dict_keys[dict_toggles[tog]])
    
    ksarg = []
    for tv in toggle_val: ksarg += [f'{tv}:1', f'{tv}:0'] # Press+release toggles to activate
    for mv in mod_val: ksarg += [f'{mv}:1'] # Press modifiers
    ksarg += [f'{key_val}:1', f'{key_val}:0'] # Press, release key
    for mv in mod_val: ksarg += [f'{mv}:0'] # Release modifiers
    for tv in toggle_val: ksarg += [f'{tv}:1', f'{tv}:0'] # Press+release toggles to revert
    
    if append_C_d: ksarg += get_keydumparg(['KEY_D',['ctrl'],[]], False)
    return ksarg;

def get_seq(ks_spec, ignore_last=True):
    chseq = '';
    if ks_spec[0:2] in blacklist: return chseq
    
    # Special handling for C-d
    if ignore_last and (ks_spec[0] == 'KEY_D') and ('ctrl' in ks_spec[1]):
        return get_seq(ks_spec, ignore_last=False)

    keydumparg = get_keydumparg(ks_spec)
    dump = subprocess.run(
         ["bash", "./keymap_dump.sh", "key"] + keydumparg,
         capture_output=True);
    dump_lines = dump.stdout.decode("ascii").split("\n")
    if(len(dump_lines) < 5): raise Exception(f"Couldn't get key sequence {ks}")
    dump_lines = dump_lines[3:-1] # Discard headers and trailing newline
    if ignore_last: dump_lines = dump_lines[:-1] # Discard final C-d
    for line in dump_lines: chseq = chseq + chr(int(line[-4:],0))
    return chseq

n_mods = len(dict_mods)
n_toggles = len(dict_toggles)
v_dims = list(dict_mods.keys()) + list(dict_toggles.keys()) # Keymap dimension labels
n_dims = len(v_dims)
n_pages = 2**(n_dims)
fmt_bin = f'{{0:0{n_dims}b}}'

# Build keymap if it doesn't already exist
if not os.path.isfile('keymap.pickle'):
    the_keymap = [['']*n_pages for _ in range(n_keymap_len)]
    for key in dict_keys.keys(): # For each key...
        for imap in range(n_pages): # For each combination of modifiers...
            # Get which modifiers/toggles are active
            v_bin = [int(i) for i in list(fmt_bin.format(imap))] 
            dict_coors = dict(zip(v_dims, v_bin)) # Keymap coordinates

            # Build a keyspec
            mods = []
            for mod in dict_mods:
                if dict_coors[mod]: mods += [mod]
            toggles = []
            for tog in dict_toggles:
                if dict_coors[tog]: toggles += [tog]

            # Observe the ASCII it produces in a terminal
            ks = [key, mods, toggles]
            print(f'getting key {ks}...')
            seq = get_seq(ks)
            ikey = dict_keys[key];
            the_keymap[ikey][imap] = seq
            print(f'sequence: {repr(seq)}\n')

    with open('./keymap.pickle', 'wb') as fd:
        pickle.dump(the_keymap, fd)

# Dump to a c header
with open('./keymap.pickle', 'rb') as fd:
    the_keymap = pickle.load(fd)

print(f'/* Autogenerated by keymap_dump.py */\n', end='')

# Key #defines
for key in dict_keys.keys():
    print(f'#define {key} {dict_keys[key]}\n', end='')

print(f'''
typedef struct kbreader_chseq {{
  unsigned int len;
  const char *ca;
}} kbreader_chseq;
''', end='')

# Populate the giant const table of keymap character sequence literals
print(f'''
const kbreader_chseq kbreader_keymap[{n_keymap_len}][{n_pages}] = {{\n''', end='')
for ikey in range(n_keymap_len):
    print(f'    {{ // {key} \n', end='')
    if ikey not in dict_keys_inv:
        print('        (kbreader_chseq) {.len=0, .ca=""}, \n'*n_pages, end='')
    else:
        key = dict_keys_inv[ikey]
        for imap in range(n_pages):
            print(f'        (kbreader_chseq) {{.len={len(list(the_keymap[ikey][imap]))}, .ca=', end='')
            for c in list(the_keymap[ikey][imap]): print(f'\"\\x{format(ord(c),"02x")}\" ', end='')
            if(len(list(the_keymap[ikey][imap])) == 0): print('""', end='')
            print(f'}}, \n', end='')
    print(f'    }},\n', end='')
print(f'}};')

# Keyboard state struct
print(f'''
struct kbreader_kbstate_t {{\n''', end='')
for imod, mod in enumerate(dict_mods.keys()):
    print(f'    unsigned int {mod};\n', end='')
for itog, tog in enumerate(dict_toggles.keys()):
    print(f'    unsigned int {tog};\n', end='')
print(f'}};\n', end='')
print(f'struct kbreader_kbstate_t kbreader_kbstate = {{0}};', end='')

# kbreader_get_page
print(f'''
unsigned int kbreader_get_page(void) {{
    unsigned int pidx = 0;\n''', end='')
for imod, mod in enumerate(dict_mods.keys()):
    print(f'    pidx += (kbreader_kbstate.{mod} << {n_dims-imod-1});\n', end='')
for itog, tog in enumerate(dict_toggles.keys()):
    print(f'    pidx += (kbreader_kbstate.{tog} << {n_dims-n_mods-itog-1});\n', end='')
print('    return pidx;\n', end='');
print(f'}}\n', end='')

# kbreader_key_press
print(f'''const kbreader_chseq* kbreader_key_press(unsigned int cidx) {{\n''', end='')
for imod, mod in enumerate(dict_mods.keys()):
    print(f'    if(', end='')
    aliases = dict_mods[mod]
    for ial in range(len(aliases)):
        print(f'(cidx == {aliases[ial]})', end='')
        if ial < len(aliases)-1: print(' || ', end='')
    print(f') kbreader_kbstate.{mod} = 1;\n', end='')
for itog, tog in enumerate(dict_toggles.keys()):
    print(f'    if(cidx == {dict_toggles[tog]}) kbreader_kbstate.{tog} = !kbreader_kbstate.{tog};\n', end='')
print('    unsigned int pidx = kbreader_get_page();\n', end='')
print('    return &kbreader_keymap[cidx][pidx];\n', end='')
print('}\n', end='')

# kbreader_key_release
print(f'''
void kbreader_key_release(unsigned int cidx) {{''')
for imod, mod in enumerate(dict_mods.keys()):
    print(f'    if(', end='')
    aliases = dict_mods[mod]
    for ial in range(len(aliases)):
        print(f'(cidx == {aliases[ial]})', end='')
        if ial < len(aliases)-1: print(' || ', end='')
    print(f') kbreader_kbstate.{mod} = 0;\n', end='')
print('    return;\n', end='')
print('}\n', end='')
