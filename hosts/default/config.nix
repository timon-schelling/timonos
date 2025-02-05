{
  opts = {
    system = {
      filesystem.drive = "/dev/<drive>"; !!! NEEDS TO BE SET MANUALLY !!!
    };
    users = {
      user = {
        # can be generated with `mkpasswd`.
        # if storing this in a git repository, consider using at least sha512 with 100000 rounds.
        # `mkpasswd -m sha-512 -R 262144`
        passwordHash = "<passwordHash>"; !!! NEEDS TO BE SET MANUALLY !!!
        home = {
          name = "User";
          email = "user@email.net";
        };
      };
    };
  };
}
