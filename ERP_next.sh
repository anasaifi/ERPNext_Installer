#!/bin/bash

# Function to check if a package is installed
package_installed() {
    dpkg -l | grep -q $1
}

# Check if the script is running on Windows or Linux
if [ "$(uname)" == "Darwin" ]; then
    echo "This script does not support macOS."
    exit 1
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Update package lists and install prerequisites
    sudo apt update
    sudo apt install -y python3-minimal python3-dev python3-setuptools python3-pip git
    # Check if MariaDB or MySQL is installed
    if ! package_installed mariadb-server && ! package_installed mysql-server; then
        # Install MariaDB
        sudo apt install -y mariadb-server
    fi
    # Clone ERPNext repository
    git clone https://github.com/frappe/bench.git ~/bench-repo
    sudo pip3 install -e ~/bench-repo
    # Create a new bench
    bench init ~/frappe-bench --frappe-branch version-13
    # Install ERPNext
    cd ~/frappe-bench
    bench get-app --branch version-13 https://github.com/frappe/erpnext.git
    # Install India Compliance
    bench get-app --branch develop https://github.com/resilient-tech/india-compliance.git
    
    #create an app
    bench new-app myapp
    
    # Create a new site
    bench new-site mysite
    # Add site to hosts
    bench --site mysite add-to-hosts
    # Install ERPNext and India Compliance apps to the new site
    bench --site mysite install-app myapp
    
    # Start the application 
    bench start
    echo "ERPNext installation complete!"
    # Redirect user to login page
    echo "You can now access ERPNext at http://myapp:8000/#login"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Update package lists
    # This step is not necessary for Windows

    # Install prerequisites
    # Python3 is not natively available on Windows 7 and 8, so we'll use WinPython
    # Install WinPython from https://github.com/winpython/winpython/releases
    # Ensure that WinPython is added to PATH during installation
    # Alternatively, you can manually set PATH to include WinPython's python.exe directory
    set PYTHON_PATH=C:\path\to\WinPython\python-3.x.x\

    # Clone ERPNext repository
    git clone https://github.com/frappe/bench.git %USERPROFILE%\bench-repo
    %PYTHON_PATH%\python.exe -m pip install -e %USERPROFILE%\bench-repo

    # Create a new bench
    %PYTHON_PATH%\python.exe %USERPROFILE%\bench-repo\bench init %USERPROFILE%\frappe-bench --frappe-branch version-13

    # Install ERPNext
    cd %USERPROFILE%\frappe-bench
    %PYTHON_PATH%\python.exe -m bench get-app --branch version-13 https://github.com/frappe/erpnext.git

    # Install India Compliance
    %PYTHON_PATH%\python.exe -m bench get-app --branch develop https://github.com/resilient-tech/india-compliance.git

    # Create a new site
    %PYTHON_PATH%\python.exe -m bench new-site mysite --mariadb-root-password 

    # Add site to hosts
    %PYTHON_PATH%\python.exe -m bench --site mysite add-to-hosts

    # Install ERPNext and India Compliance apps to the new site
    %PYTHON_PATH%\python.exe -m bench --site mysite install-app erpnext
    %PYTHON_PATH%\python.exe -m bench --site mysite install-app india_compliance

    # Start the application 
    %PYTHON_PATH%\python.exe -m bench start

    echo ERPNext installation complete!
    # Redirect user to login page
    echo "You can now access ERPNext at http://myapp:8000/#login"
else
    echo "Unsupported operating system."
    exit 1
fi

