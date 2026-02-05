#!/usr/bin/env python3
import paramiko
import time
import csv
import os
import json
import pandas as pd 
from otii_tcp_client import otii_client


class AppException(Exception):
    '''Application Exception'''

def write_record_to_csv(distro, row):
    headers = ["RPi", "Distro", "Version", "From", "To", "Offset", "Sample rate", "Min", "Max","Average","Mean",
               "1st quantile", "3rd quantile", "Duration", "Total Energy consumption", "Standard Deviation"]
    file_path = f"../../results/results_{distro}.csv"
    file_exists = os.path.isfile(file_path)        
    with open(file_path, mode="a", newline="") as file:
        writer = csv.writer(file)
        if not file_exists:
            writer.writerow(headers)
        writer.writerow(row)


def extract_data_from_recording(project, device, rpi, distro, python_version):
    # Setup recording and data extraction
    recording = project.get_last_recording()
    recording.rename(f"recording_{rpi}_{distro}_{python_version}")

    info = recording.get_channel_info(device.id, 'mp')
    statistics_mp = recording.get_channel_statistics(device.id, 'mp', info['from'], info['to'])
    data_count = recording.get_channel_data_count(device.id, 'mp')
    data = recording.get_channel_data(device.id, 'mp', 0, data_count)['values']
    df = pd.DataFrame(data, columns=['watt'])
    
    # Key statistics from recording
    duration = info["to"] - info["from"]
    max_watt = statistics_mp["max"]
    min_watt = statistics_mp["min"]
    average_watt = statistics_mp["average"]
    total_energy_joules = duration * average_watt
        
    # Derived statistics
    std = df['watt'].std()
    mean = df['watt'].mean()
    q1 = df['watt'].quantile(0.25)
    q3 = df['watt'].quantile(0.75)

    # Create data record

    row = [
            rpi, 
            distro,
            python_version,
            info["from"],
            info["to"],
            info["offset"],
            info["sample_rate"],
            round(min_watt, 3),
            round(max_watt, 3),
            round(mean, 3),
            round(q1, 3),
            round(q3, 3),
            round(average_watt, 3),
            round(duration, 3),
            round(total_energy_joules, 3),
            round(std, 3)
        ]
    
    return row    
                                                        

def run_benchmarks(rpi, distro, python_version, hostname, username, password):
    # Define command to run script
    command = f"bash ~/cpython_application_energy_consumption/scripts/experiment/run_benchmarks.sh {python_version}" 

    try:
        # Create an SSH client
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # Connect to the SSH server
        print(f"Connecting to {username}@{hostname}...")
        ssh_client.connect(hostname, 22, username=username, password=password)
        print("Connection established.")

        # Execute the run_benchmarks script and start recording 
        project.start_recording()
        print(f"Running command: {command}")
        stdin, stdout, stderr = ssh_client.exec_command(command)
        
        # Wait for the command to complete and fetch outputs
        exit_status = stdout.channel.recv_exit_status()
        print(f"Command completed with exit status: {exit_status}")

        project.stop_recording()

        # Print the standard output and error
        print("Standard Output:")
        for line in stdout.read().decode().splitlines():
            print(line)

        print("Standard Error:")
        for line in stderr.read().decode().splitlines():
            print(line)

        # Execute the command
        print(f"Running command: rm {python_version}.json")
        stdin, stdout, stderr = ssh_client.exec_command(f"rm {python_version}.json")

        # Wait for the command to complete and fetch outputs
        exit_status = stdout.channel.recv_exit_status()
        print(f"Command completed with exit status: {exit_status}")

        # Print the standard output and error
        print("Standard Output:")
        for line in stdout.read().decode().splitlines():
            print(line)

        print("Standard Error:")
        for line in stderr.read().decode().splitlines():
            print(line)
            
    except Exception as e:
        print(f"An error occurred: {e}")
    
    finally:
        # Close the connection
        ssh_client.close()
        print("Connection closed.")

    # Get statistics for the recording
    time.sleep(10)
    
    row = extract_data_from_recording(project, device, rpi, distro, python_version)

    write_record_to_csv(distro, row)


def main(rpi, distro, version, hostname, username, password):
    '''Connect to the Otii 3 application and run the measurement'''
    try:
        run_benchmarks( rpi, distro, version, hostname, username, password)
    except Exception as error:
        print(f"Something went wrong: {error}. Retrying")
        run_benchmarks(rpi, distro, version, hostname, username, password)

if __name__ == '__main__':
    client = otii_client.OtiiClient()
    with client.connect() as otii:
        #Get a reference to a Arc or Ace device
        devices = otii.get_devices()
        if len(devices) == 0:
            raise AppException('No Arc or Ace connected!')
        device = devices[0]

        #Configure the device
        device.set_main_voltage(5.15)
        #Deprecated device.set_exp_voltage(4.9)
        device.set_max_current(3.0)

        # Enable the main power channel
        device.enable_channel('mp', True)

        # Get the active project
        project = otii.get_active_project()
        with open("pi_credentials.json") as f:
            credentials = json.load(f)
            
            print(f"Running python 3.13")
            try:
                main("RPi4B", "Ubuntu", "3.13.7", credentials["hostname"], credentials["username"], credentials["password"])
                time.sleep(5)
            except Exception as error:
                print(f"Something went wrong: {error}.")
                time.sleep(10)
            print(f"Running python 3.12")
            try:
                main("RPi4B", "Ubuntu", "3.12.11", credentials["hostname"], credentials["username"], credentials["password"])
                time.sleep(5)
            except Exception as error:
                print(f"Something went wrong: {error}.")
                time.sleep(10)
            print(f"Running python 3.11")
            try:
                main("RPi4B", "Ubuntu", "3.11.13", credentials["hostname"], credentials["username"], credentials["password"])
                time.sleep(5)
            except Exception as error:
                print(f"Something went wrong: {error}.")
                time.sleep(10)
            print(f"Running python 3.10")
            try:
                main("RPi4B", "Ubuntu", "3.10.18", credentials["hostname"], credentials["username"], credentials["password"])
                time.sleep(5)
            except Exception as error:
                print(f"Something went wrong: {error}.")
                time.sleep(10)
            print(f"Running python 3.9")
            try:
                main("RPi4B", "Ubuntu", "3.9.23", credentials["hostname"], credentials["username"], credentials["password"])
                time.sleep(5)
            except Exception as error:
                print(f"Something went wrong: {error}.")
                time.sleep(10)