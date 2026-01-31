start_all()

machine.wait_for_unit("home-manager-alice.service")

uid = machine.succeed("id -u alice").strip()
machine.succeed("loginctl enable-linger alice")
machine.succeed(f"systemctl start user@{uid}.service")
machine.wait_for_unit(f"user@{uid}.service")

machine.succeed("su - alice -c 'systemctl --user daemon-reload'")
machine.succeed("su - alice -c 'systemctl --user start openclaw-gateway.service'")
machine.wait_for_unit("openclaw-gateway.service", user="alice")

machine.wait_for_open_port(18999)

machine.succeed("test -f /home/alice/.openclaw/openclaw.json")
