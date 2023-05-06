#!/bin/bash

# Checking for sudo or root privileges
if [[ $(id -u) -ne 0 ]]; then
  echo "Error: This script requires sudo or root privileges to run."
  echo "Please run the script again with sudo or as root."
  exit 1
fi

# Function to perform the firewall action
perform_firewall_action() {
  action=$1

  if [ "$action" = "add" ]; then
    # Get the current default zone
    default_zone=$(firewall-cmd --get-default-zone)
    echo "Current Default Zone: $default_zone"
    echo

    # List available firewall zones
    echo "Available Firewall Zones:"
    firewall-cmd --get-zones
    echo

    # Prompt for firewall zone
    read -p "Enter the name of the firewall zone you want to add (leave blank for default zone): " zone_name
    echo

    # If zone_name is empty, use the default zone
    if [ -z "$zone_name" ]; then
      zone_name="$default_zone"
    fi

    # Prompt for firewall rule details
    echo "Adding a rule for Zone: $zone_name"
    echo
    read -p "Enter the source address or subnet (leave blank for 'any'): " source_address

    if [ -z "$source_address" ]; then
      source_address="0.0.0.0/0"
    fi

    echo
    read -p "Enter the destination port ('any' for all ports): " destination_port

    if [ "$destination_port" = "any" ]; then
      destination_port=""
    else
      # Validate if the destination port is a number
      if ! [[ "$destination_port" =~ ^[0-9]+$ ]]; then
        echo "Invalid destination port. Returning back to the menu."
        return
      fi
    fi

    echo
    read -p "Enter the protocol (tcp/udp): " protocol
    echo
    read -p "Enter the action (allow/deny/reject): " rule_action

    # Convert the 'allow' action to 'accept'
    if [ "$rule_action" = "allow" ]; then
      rule_action="accept"
    fi

    # Convert the 'deny' action to 'drop'
    if [ "$rule_action" = "deny" ]; then
      rule_action="drop"
    fi

    # Add the firewall rule
    firewall-cmd --permanent --zone="$zone_name" --add-rich-rule="rule family='ipv4' source address='$source_address' port port='$destination_port' protocol='$protocol' $rule_action"
    add_status=$?

    if [ $add_status -eq 0 ]; then
      echo "Firewall rule added successfully to Zone: $zone_name"
      echo

      # Prompt to reload firewalld
            read -p "Do you want to reload firewalld to apply the configuration? (y/n): " reload_firewalld
      echo

      if [ "$reload_firewalld" = "y" ]; then
        # Reload firewalld
        firewall-cmd --reload
        reload_status=$?

        if [ $reload_status -eq 0 ]; then
          echo "Firewalld reloaded successfully!"
          echo

          # Clear the screen
          clear

          # List active rules
          echo "Active Firewall Rules:"
          firewall-cmd --zone="$zone_name" --list-all
          echo

          # Prompt to return to the main menu or exit
          read -p "Press 'm' to return to the main menu or 'q' to exit: " menu_choice

          if [ "$menu_choice" = "m" ]; then
            clear
            continue
          elif [ "$menu_choice" = "q" ]; then
            exit 0
          else
            echo "Invalid choice. Returning to the main menu."
            sleep 1
            clear
            continue
          fi
        fi
      else
        echo "Failed to add firewall rule. Please check the firewalld configuration."
      fi
    fi
  elif [ "$action" = "delete" ]; then
    # Get the current default zone, list available zones and prompt for zone_name
    default_zone=$(firewall-cmd --get-default-zone)
    echo "Current Default Zone: $default_zone"
    echo

    echo "Available Firewall Zones:"
    firewall-cmd --get-zones
    echo

    read -p "Enter the name of the firewall zone you want to delete the rule from (leave blank for default zone): " zone_name
    echo

    # If zone_name is empty, use the default zone
    if [ -z "$zone_name" ]; then
      zone_name="$default_zone"
    fi

    # List the rules in the specified zone
    echo "Firewall Rules in Zone $zone_name:"
    firewall-cmd --zone="$zone_name" --list-rich-rules
    echo

    # Prompt for the rule number to delete
    read -p "Copy and Paste the rule as you see it that you want to delete: " rich_rule
    echo

    # Delete the specified rule
    firewall-cmd --permanent --zone="$zone_name" --remove-rich-rule="$rich_rule"
    delete_status=$?

    if [ $delete_status -eq 0 ]; then
      echo "Firewall rule $rich_rule deleted successfully from Zone: $zone_name"
      echo

      # Prompt to reload firewalld
      read -p "Do you want to reload firewalld to apply the configuration? (y/n): " reload_firewalld
      echo

      if [ "$reload_firewalld" = "y" ]; then
        # Reload firewalld
        #firewall-cmd --reload
        systemctl reload firewalld
        reload_status=$?

        if [ $reload_status -eq 0 ]; then
          echo "Firewalld reloaded successfully!"
          echo

          # Clear the screen
          clear

          # List active rules
          echo "Active Firewall Rules:"
          firewall-cmd --zone="$zone_name" --list-all
          echo

          # Prompt to return to the main menu or exit
          read -p "Press 'm' to return to the main menu or 'q' to exit: " menu_choice

          if [ "$menu_choice" = "m" ]; then
            clear
            continue
          elif [ "$menu_choice" = "q" ]; then
            exit 0
          else
            echo "Invalid choice. Returning to the main menu."
            sleep 1
            clear
            continue
          fi
        fi
      else
        echo "Failed to delete firewall rule. Please check the firewalld configuration."
      fi
    fi
  fi
}

# Clear the screen
clear

# Firewalld ASCII art
echo -e "\e[34m
 ,__ __                  _           ______                            _   _        
/|  |  |          |  o  | |         (_) |  o                          | | | |
 |  |  |   __   __|     | |            _|_     ,_    _           __,  | | | |  __|
 |  |  |  /  \_/  |  |  |/  |   |     / | ||  /  |  |/  |  |  |_/  |  |/  |/  /  |
 |  |  |_/\__/ \_/|_/|_/|__/ \_/|/   (_/   |_/   |_/|__/ \/ \/  \_/|_/|__/|__/\_/|_/
                        |\     /|
                        |/     \|
\e[0m"

# Set the font color to yellow
tput setaf 3

echo
echo "Simplifying the process"
echo "Author: bdorr1105"
echo "Version Date: 5 May"
echo

# Reset the font color
tput sgr0

# Check firewalld status
firewalld_status=$(systemctl is-active firewalld)

if [ "$firewalld_status" = "inactive" ]; then
  echo
  echo "Firewalld is currently disabled."
  echo
  read -p "Do you want to enable Firewalld and allow SSH from anywhere? (y/n): " enable_firewalld

  if [ "$enable_firewalld" = "y" ]; then
    # Allow SSH from anywhere
    firewall-cmd --add-service=ssh --permanent

    # Enable Firewalld
    systemctl enable --now firewalld
    enable_status=$?

    if [ $enable_status -eq 0 ]; then
      echo "Firewalld has been enabled and SSH is allowed from anywhere."
    else
      echo "Failed to enable Firewalld. Please check the firewalld configuration."
      exit 1
    fi
  else
    echo "Firewalld remains disabled. Exiting script."
    exit 0
  fi
fi

while true; do
  # Menu
  echo
  echo "Selection Menu:"
  echo
  echo "1. Check the status of Firewalld"
  echo "2. List Current Firewall Rules"
  echo "3. Modify firewall rules"
  echo "4. Reload Firewalld"
  echo "5. Disable Firewalld"
  echo "6. Enable Firewalld"
  echo
  read -p "Enter your selection: " menu_selection
  echo

  case $menu_selection in
    1)
      # Check Firewalld status
      systemctl status firewalld
      ;;

    2)
      # List current firewall rules
      firewall-cmd --list-all
      echo

      # Prompt to return to the main menu or exit
      read -p "Press 'm' to return to the main menu or 'q' to exit: " menu_choice

      if [ "$menu_choice" = "m" ]; then
        clear
        continue
      elif [ "$menu_choice" = "q" ]; then
        exit 0
      else
        echo "Invalid choice. Returning to the main menu."
        sleep 1
        clear
        continue
      fi
      ;;

    3)
      # Prompt for action to perform
      read -p "Do you want to add a rule or delete a rule (add/delete/menu): " action
      clear

      # Perform the specified action
      perform_firewall_action "$action"
      ;;

    4)
      # Reload Firewalld
      #firewall-cmd --reload
      systemctl reload --now firewalld
      reload_status=$?

      if [ $reload_status -eq 0 ]; then
        echo "Firewalld has been reloaded."
      else
        echo "Failed to reload Firewalld. Please check the firewalld configuration."
        exit 1
      fi
      ;;

    5)
      # Disable Firewalld
      systemctl disable --now firewalld
      disable_status=$?

      if [ $disable_status -eq 0 ]; then
        echo "Firewalld has been disabled."
      else
        echo "Failed to disable Firewalld. Please check the firewalld configuration."
        exit 1
      fi
      ;;

    6)
      # Enable Firewalld
      systemctl enable --now firewalld
      enable_status=$?

      if [ $enable_status -eq 0 ]; then
        echo "Firewalld has been enabled."
      else
        echo "Failed to enable Firewalld. Please check the firewalld configuration."
        exit 1
      fi
      ;;
    *)
      echo "Invalid selection. Returning to the main menu."
      sleep 1
      clear
      continue
      ;;
  esac
done

# Clear the screen
clear

# List Firewalld status
firewall-cmd --list-all
