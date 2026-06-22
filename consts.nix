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
    # Qwen3.6 27B dense @ Q6: 26 GB
    qwen27b = "unsloth/Qwen3.6-27B-MTP-GGUF:Q6_K";
    # Qwen3.6 35B-A3B @ UD-Q4_K_S: 21.4 GB
    qwen35b = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
    # Gemma 4 31B @ Q4_K_M: 18.3 GB
    gemma31b = "unsloth/gemma-4-31B-it-GGUF:Q4_K_M";
    # Gemma 4 26B-A4B with QAT and mtp enabled @ 14.2 GB
    gemma26b = "unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL";
  };
}