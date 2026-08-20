#!/usr/bin/env python3
"""Generate chiptune audio assets for Tamabrawler using only Python stdlib."""
import wave
import struct
import math
import os

OUT = os.path.join(os.path.dirname(__file__), "audio")
SAMPLE_RATE = 22050  # lo-fi 8-bit vibe

def note_to_freq(note, octave=4):
    """Convert a note name + octave to frequency (A4=440Hz)."""
    notes = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 
             'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}
    semitone = notes[note] + (octave - 4) * 12
    return 440.0 * (2.0 ** (semitone / 12.0))

def gen_tone(freq, duration, volume=0.5, wave_type='square'):
    """Generate a waveform buffer."""
    n_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        if wave_type == 'square':
            val = 1.0 if (t * freq) % 1 < 0.5 else -1.0
        elif wave_type == 'saw':
            val = 2.0 * ((t * freq) % 1) - 1.0
        elif wave_type == 'triangle':
            phase = (t * freq) % 1
            val = 4.0 * abs(phase - 0.5) - 1.0
        elif wave_type == 'noise':
            import random
            val = random.random() * 2 - 1
        else:  # sine
            val = math.sin(2 * math.pi * freq * t)
        # Apply envelope (quick attack, short sustain, quick release)
        env = 1.0
        attack = 0.01
        release = 0.05
        if t < attack:
            env = t / attack
        elif t > duration - release:
            env = max(0, (duration - t) / release)
        # Square sample at 8-bit
        sample = int(127 * volume * env * val)
        samples.append(sample)
    return samples

def gen_multi_tone(notes, wave_type='square'):
    """Generate a sequence of notes (list of (freq, duration) tuples)."""
    all_samples = []
    for freq, dur, vol in notes:
        all_samples.extend(gen_tone(freq, dur, vol, wave_type))
    return all_samples

def write_wav(filename, samples):
    """Write samples to a WAV file (unsigned 8-bit)."""
    path = os.path.join(OUT, filename)
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(1)  # 8-bit
        w.setframerate(SAMPLE_RATE)
        # Convert signed int (-128..127) to unsigned (0..255)
        unsigned = bytes([(s + 128) & 0xFF for s in samples])
        w.writeframes(unsigned)
    print(f"✅ Saved {filename}")
    return path

def gen_eat_sound():
    """Cute 'nom nom' chirp."""
    notes = [
        (note_to_freq('C', 5), 0.05, 0.4),
        (note_to_freq('E', 5), 0.05, 0.4),
        (note_to_freq('G', 5), 0.08, 0.3),
    ]
    write_wav("eat.wav", gen_multi_tone(notes, 'square'))

def gen_sleep_sound():
    """Gentle descending lullaby."""
    notes = [
        (note_to_freq('E', 4), 0.3, 0.3),
        (note_to_freq('D', 4), 0.3, 0.3),
        (note_to_freq('C', 4), 0.4, 0.2),
    ]
    write_wav("sleep.wav", gen_multi_tone(notes, 'triangle'))

def gen_hurt_sound():
    """Quick descending buzz - ouch."""
    notes = [
        (note_to_freq('C', 4), 0.05, 0.5),
        (note_to_freq('G#', 3), 0.05, 0.4),
        (note_to_freq('F', 3), 0.1, 0.3),
    ]
    write_wav("hurt.wav", gen_multi_tone(notes, 'saw'))

def gen_attack_sound():
    """Punchy staccato burst."""
    notes = [
        (note_to_freq('C', 5), 0.02, 0.7),
        (note_to_freq('E', 5), 0.02, 0.6),
        (note_to_freq('G', 5), 0.04, 0.5),
        (note_to_freq('C', 6), 0.06, 0.4),
    ]
    write_wav("attack.wav", gen_multi_tone(notes, 'square'))

def gen_victory_sound():
    """Ascending cheer - da da DAAAA!"""
    notes = [
        (note_to_freq('C', 4), 0.15, 0.4),
        (note_to_freq('E', 4), 0.15, 0.4),
        (note_to_freq('G', 4), 0.15, 0.4),
        (note_to_freq('C', 5), 0.3, 0.5),
    ]
    write_wav("victory.wav", gen_multi_tone(notes, 'square'))

def gen_death_sound():
    """Sad descending tone."""
    notes = [
        (note_to_freq('C', 5), 0.2, 0.4),
        (note_to_freq('B', 4), 0.2, 0.3),
        (note_to_freq('A', 4), 0.2, 0.3),
        (note_to_freq('G', 4), 0.3, 0.2),
        (note_to_freq('F', 4), 0.4, 0.1),
    ]
    write_wav("death.wav", gen_multi_tone(notes, 'triangle'))

def gen_bgm_loop():
    """Simple 8-bit background music loop (~8 seconds)."""
    melody = [
        # Measure 1
        (note_to_freq('C', 4), 0.3, 0.2),
        (note_to_freq('E', 4), 0.3, 0.2),
        (note_to_freq('G', 4), 0.3, 0.2),
        (note_to_freq('C', 5), 0.3, 0.2),
        # Measure 2
        (note_to_freq('A', 4), 0.3, 0.2),
        (note_to_freq('G', 4), 0.3, 0.2),
        (note_to_freq('F', 4), 0.3, 0.2),
        (note_to_freq('E', 4), 0.3, 0.2),
        # Measure 3
        (note_to_freq('F', 4), 0.3, 0.2),
        (note_to_freq('A', 4), 0.3, 0.2),
        (note_to_freq('C', 5), 0.3, 0.2),
        (note_to_freq('A', 4), 0.3, 0.2),
        # Measure 4
        (note_to_freq('G', 4), 0.3, 0.2),
        (note_to_freq('F', 4), 0.3, 0.2),
        (note_to_freq('E', 4), 0.3, 0.2),
        (note_to_freq('C', 4), 0.3, 0.2),
        # Repeat higher
        (note_to_freq('C', 5), 0.3, 0.2),
        (note_to_freq('E', 5), 0.3, 0.2),
        (note_to_freq('G', 5), 0.3, 0.2),
        (note_to_freq('C', 6), 0.3, 0.2),
        (note_to_freq('A', 5), 0.3, 0.2),
        (note_to_freq('G', 5), 0.3, 0.2),
        (note_to_freq('F', 5), 0.3, 0.2),
        (note_to_freq('E', 5), 0.3, 0.2),
        (note_to_freq('F', 5), 0.3, 0.2),
        (note_to_freq('A', 5), 0.3, 0.2),
        (note_to_freq('C', 6), 0.3, 0.2),
        (note_to_freq('A', 5), 0.3, 0.2),
        (note_to_freq('G', 5), 0.3, 0.2),
        (note_to_freq('F', 5), 0.3, 0.2),
        (note_to_freq('E', 5), 0.3, 0.2),
        (note_to_freq('C', 5), 0.3, 0.2),
    ]
    # Add bass line
    bass = [
        (note_to_freq('C', 3), 1.2, 0.3),
        (note_to_freq('F', 3), 1.2, 0.3),
        (note_to_freq('G', 3), 1.2, 0.3),
        (note_to_freq('C', 3), 1.2, 0.3),
    ]
    mel_samples = gen_multi_tone(melody, 'square')
    bass_samples = gen_multi_tone(bass, 'triangle')
    # Mix (repeat bass to match melody length)
    while len(bass_samples) < len(mel_samples):
        bass_samples.extend(bass_samples[:len(mel_samples)-len(bass_samples)])
    mixed = []
    for i in range(len(mel_samples)):
        m = mel_samples[i] if i < len(mel_samples) else 0
        b = bass_samples[i] if i < len(bass_samples) else 0
        combined = (m + b) // 2
        mixed.append(max(-128, min(127, combined)))
    write_wav("bgm_loop.wav", mixed)

def main():
    os.makedirs(OUT, exist_ok=True)
    gen_eat_sound()
    gen_sleep_sound()
    gen_hurt_sound()
    gen_attack_sound()
    gen_victory_sound()
    gen_death_sound()
    gen_bgm_loop()

if __name__ == "__main__":
    main()