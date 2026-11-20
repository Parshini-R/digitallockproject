# FSM state description

- **LOCKED**: waits for submit pulse.
- **CHECK**: compares entered 4-bit code against password.
- **FAIL**: unsuccessful attempt; returns to LOCKED.
- **UNLOCKED**: correct password; stays unlocked until reset.
- **LOCKOUT**: entered three consecutive wrong passwords; stays locked until reset.

Transitions:
- LOCKED --submit--> CHECK
- CHECK --correct--> UNLOCKED
- CHECK --wrong, failures < 2--> FAIL
- CHECK --wrong, failures >= 2--> LOCKOUT
- FAIL --> LOCKED
- UNLOCKED --> UNLOCKED
- LOCKOUT --> LOCKOUT
- Any state --reset--> LOCKED, attempts=0
