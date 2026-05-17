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

  # Models
  models = {
    # Qwen3.6 27B dense @ Q5_K_M — 19.8 GB
    qwen27b = "unsloth/Qwen3.6-27B-MTP-GGUF:Q5_K_M";
    # Qwen3.6 35B-A3B @ UD-Q4_K_S: 21.4 GB
    qwen35b = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_S";
    # Gemma 4 31B @ Q5_K_M: 21.7 GB
    gemma31b = "unsloth/gemma-4-31B-it-GGUF:Q5_K_M";
  };
}