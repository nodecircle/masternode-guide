# NodeCircle(NCX) Cold MasterNode setup guide

> Feel free to suggest improvements via Issues or opening Pull Requests. Thank you!

## Part 1: VPS Wallet Setup
We recommend you to run the remote wallet in a vps wth Linux Ubuntu 16.04 installed and hosted by Vultr, AWS or Digital Ocean, make sure you have ssh access to the machine.
The server will run 24/7 with a wallet with no funds, reducing the risk of loosing the funds in the event of an attack.

1. Get a VPS server.

Requirements:
 * Linux VPS (Debian, Ubuntu or similar)
 * Static IPv4 Address
 * Recommended at least 1GB of RAM

2. SSH into the server and run our installation script:

```
rm -f install_mn.sh && wget https://raw.githubusercontent.com/nodecircle/masternode-guide/master/install_mn.sh && sh install_mn.sh
```

3. Wait until the script is finished (around 10 minutes):

4. The output should be something like this
```
INSTALLED WITH VPS IP: 123.321.123.32:18775
INSTALLED WITH GENKEY: 6sg8KrK4Uee4r8kjthzczwQ3r1ZYnaCknWvVY7EaMG6MgVthi9W
```

5. Copy those values in order to use them on your local wallet.


## Part 2: Local wallet setup (Windows, Mac or Linux)

This is the wallet where the MasterNode collateral of 50,000NCX will be stored. After the setup is complete, this wallet doesn't have to run 24/7 and will be the one receiving the rewards.
If you let the wallet opened and unlocked you can stake the coins that you will receive as erward for the masternode.

1. Open NCX wallet on desktop.

   Go to Settings -> Options -> Wallet

   Check "Enable coin control features"

   Check "Show Masternodes Tab"

   Press **Ok**

   Restart NCX Wallet and wait until it syncs to the network.

2. Create a receiving address for the Masternode payee (If you have received exactly 50,000NCX already, jump to step 6).

   Go to Receive -> Set your label (ex: MN01), press **Request Payment** and copy your new address.


3. Go to Send.
4. Send exactly 50,000NCX to the address you just copied. Please make sure this is the right address.
5. After sending wait few minutes for the confirmation by the network.
6. Open the debug console of the wallet.

   Go to `Tools` -> `Debug console`

7. Run `masternode outputs` command to retrieve the transaction ID of the collateral transfer.

   You should be able to see an output like this:
   ```
   [
      {
        "txhash" : "20175hcn6a76fa557370ec3bbc13af0d0df3d4df63adc018e1dd90m4h6la5m61",
        "outputidx" : 0
      }
   ]
   ```

   Both `txhash` and `outputidx` will be used in the next step.

9. Go to `Tools` -> `Open Masternode Configuration File` and add a line in the opened `masternode.conf` file. The new line should contain the information about your vps server and the output of the previous step, following this format: LABEL IP:PORT GENKEY OUTPUT INDEX
   ```
   MN01 123.321.123.32:18775 6sg8KrK4Uee4r8kjthzczwQ3r1ZYnaCknWvVY7EaMG6MgVthi9W 20175hcn6a76fa557370ec3bbc13af0d0df3d4df63adc018e1dd90m4h6la5m61 0
   ```

10. Restart the wallet to pick up configuration changes.
11. Go to Masternodes tab and check if your newly added masternode is listed under the `Masternodes` tab, unlock your wallet and click on click `Start MISSING` button.
12. Give it a few minutes and go to the VPS console and check the status of the masternode with this command:
```
nodecircle-cli masternode status
```

If you see status `Masternode successfully started` that's it, just wait a few hours until the first rewards start coming in.

Note: If you want to control multiple masternodes from this local wallet, for adding a new masternode you just need to send another 50,000NCX, get the output from the debug window and add a new line to the masternode.conf file.
