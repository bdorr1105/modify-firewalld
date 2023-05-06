![modify-firewall-D Menu](https://user-images.githubusercontent.com/12386911/236648943-20e334b8-1168-4087-bba6-b3805d5520ec.png)

# modify-firewalld
This is a script that will allow you to modify the firewalld rules on RHEL based systems. It will ask prompts and build the rule based on your input, delete them if you wish and list what is already there.
## Usage
To use this script, follow the steps below:

### Clone this repository to your local machine:

`git clone https://github.com/bdorr1105/modify-firewalld.git`

### Change to the project directory:

`cd modify-firewalld`

### Make the script executable:

`chmod +x modify-firewalld.sh`

Run the script sudo/root privs:

`sudo ./modify-firewalld.sh`

## Follow the prompts and provide the required information to build your custom firewall rule.

Once the rule is generated, the script will apply the changes to firewalld.

| :point_up:    | Please note that running this script may require administrative privileges, so ensure that you have the necessary permissions before executing it. |
|---------------|:---------------------------------------------------------------------------------------------------------------------------------------------------|

|:exclamation:  Warning   Modifying firewall settings can have significant security implications. Make sure you understand the consequences of the changes you make and review the generated firewall rule before applying it.|
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

## Check out the Demo
[![Firewalld Demo](https://img.youtube.com/vi/t9b0rgQcyaw.jpg)](http://www.youtube.com/watch?v=t9b0rgQcyaw)

## Contributions
Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please feel free to create a pull request or submit an issue on the GitHub repository.

## License
This script is licensed under the GNU License. Please review the license file for more information.

