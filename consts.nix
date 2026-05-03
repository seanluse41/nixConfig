{
  network = {
    homeServer = "192.168.50.110";
    photoFrame = "192.168.50.139";
    piHole = "192.168.50.84";
    pi256 = "192.168.50.191";
    aiServer = "192.168.50.49";
  };
  
  ports = {
    udpReboot = 9999;
    ssh = 22;
    http = 80;
    https = 443;
    immich = 8080;
  };
  
  user = "sean";
}