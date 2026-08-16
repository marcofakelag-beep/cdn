#!/bin/bash

# ==========================================
# XITEXE PROXY V9 - Startup Script
# ==========================================
# Author: XITEXE
# Version: 9.0
# Description: Secure access gateway proxy server
# ==========================================

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==========================================
# FUNCTIONS
# ==========================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ██╗  ██╗██╗████████╗███████╗██╗  ██╗███████╗                ║"
    echo "║  ╚██╗██╔╝██║╚══██╔══╝██╔════╝╚██╗██╔╝██╔════╝                ║"
    echo "║   ╚███╔╝ ██║   ██║   █████╗   ╚███╔╝ █████╗                  ║"
    echo "║   ██╔██╗ ██║   ██║   ██╔══╝   ██╔██╗ ██╔══╝                  ║"
    echo "║  ██╔╝ ██╗██║   ██║   ███████╗██╔╝ ██╗███████╗                ║"
    echo "║  ╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝                ║"
    echo "║                                                               ║"
    echo "║  ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗                  ║"
    echo "║  ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝                  ║"
    echo "║  ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝                   ║"
    echo "║  ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝                    ║"
    echo "║  ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║                     ║"
    echo "║  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝                     ║"
    echo "║                                                               ║"
    echo "║  ╔═══════════════════════════════════════════════════════════╗ ║"
    echo "║  ║  🔥 XITEXE PROXY V9.0  |  SECURE ACCESS GATEWAY        ║ ║"
    echo "║  ╚═══════════════════════════════════════════════════════════╝ ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_separator() {
    echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
}

# ==========================================
# CHECK ENVIRONMENT
# ==========================================

check_environment() {
    print_separator
    print_info "Checking environment..."
    echo ""
    
    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v)
        print_success "Node.js version: $NODE_VERSION"
    else
        print_error "Node.js is not installed!"
        print_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm -v)
        print_success "npm version: $NPM_VERSION"
    else
        print_error "npm is not installed!"
        print_info "Installing npm..."
        apt-get install -y npm
    fi
    
    echo ""
}

# ==========================================
# INSTALL DEPENDENCIES
# ==========================================

install_dependencies() {
    print_separator
    print_info "Installing dependencies..."
    echo ""
    
    if [ -f "package.json" ]; then
        print_info "Found package.json"
        
        if ! command -v serve &> /dev/null; then
            print_info "Installing serve globally..."
            npm install -g serve
        else
            print_success "serve is already installed"
        fi
        
        print_info "Installing local dependencies..."
        npm install
        print_success "Dependencies installed successfully"
    else
        print_warning "package.json not found! Creating..."
        cat > package.json << EOF
{
    "name": "xitexe-proxy",
    "version": "9.0.0",
    "scripts": {
        "start": "npx serve -l 8080"
    },
    "dependencies": {
        "serve": "^14.2.1"
    }
}
EOF
        npm install
    fi
    
    echo ""
}

# ==========================================
# CHECK CDN FILES
# ==========================================

check_cdn_files() {
    print_separator
    print_info "Checking CDN files..."
    echo ""
    
    CACHE_RES_PATH="cdn/live/ABHotUpdates/android_astc/1.130.20/gameassetbundles/cache_res.1Z~2FwrIKwQQ9HOE~2BKu7UXEuulxew~3D"
    if [ -f "$CACHE_RES_PATH" ]; then
        FILE_SIZE=$(du -h "$CACHE_RES_PATH" | cut -f1)
        print_success "cache_res found (Size: $FILE_SIZE)"
    else
        print_warning "cache_res not found locally"
        print_info "Will download from CDN when requested"
    fi
    
    FILEINFO_PATH="cdn/live/ABHotUpdates/android_astc/1.130.20/fileinfo"
    if [ -f "$FILEINFO_PATH" ]; then
        FILE_SIZE=$(du -h "$FILEINFO_PATH" | cut -f1)
        print_success "fileinfo found (Size: $FILE_SIZE)"
    else
        print_warning "fileinfo not found locally"
        print_info "Will download from CDN when requested"
    fi
    
    echo ""
}

# ==========================================
# CHECK PORT
# ==========================================

check_port() {
    PORT=${PORT:-8080}
    print_info "Checking port $PORT..."
    
    if lsof -i:$PORT &> /dev/null; then
        print_warning "Port $PORT is already in use!"
        PORT=$((PORT+1))
    fi
    
    print_success "Using port: $PORT"
    export PORT=$PORT
    echo ""
}

# ==========================================
# START SERVER
# ==========================================

start_server() {
    print_separator
    echo ""
    print_success "🚀 Starting XITEXE PROXY V9..."
    print_info "Server will be available at: http://0.0.0.0:$PORT"
    print_info "Press Ctrl+C to stop"
    echo ""
    print_separator
    echo ""
    
    if [ -f "index.html" ]; then
        print_success "Found index.html"
    else
        print_error "index.html not found!"
        exit 1
    fi
    
    print_info "Starting serve on port $PORT..."
    npx serve -l $PORT .
}

# ==========================================
# ERROR HANDLING
# ==========================================

handle_error() {
    print_error "An error occurred during startup!"
    
    if [ ! -f "index.html" ]; then
        print_error "index.html is missing!"
    fi
    
    if [ ! -d "node_modules" ]; then
        print_warning "node_modules not found, installing..."
        npm install
    fi
    
    echo ""
    print_info "Try running manually: npx serve -l 8080"
    exit 1
}

# ==========================================
# CLEANUP
# ==========================================

cleanup() {
    echo ""
    print_separator
    print_warning "Shutting down XITEXE PROXY V9..."
    print_success "Goodbye! 👋"
    print_separator
    exit 0
}

# ==========================================
# MAIN EXECUTION
# ==========================================

trap cleanup SIGINT SIGTERM

clear
print_banner

print_info "System Information:"
echo -e "${CYAN}📅 Date: $(date)${NC}"
echo -e "${CYAN}💻 Host: $(hostname)${NC}"
echo -e "${CYAN}📂 Directory: $(pwd)${NC}"
echo ""

check_environment
install_dependencies
check_cdn_files
check_port

start_server

if [ $? -ne 0 ]; then
    handle_error
fi