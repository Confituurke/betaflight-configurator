#!/bin/bash

# Betaflight Configurator Docker Development Script
# This script provides easy commands to manage the Docker development environment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to get the correct docker compose command
get_docker_compose() {
    if command -v docker-compose > /dev/null 2>&1; then
        echo "docker-compose"
    elif docker compose version > /dev/null 2>&1; then
        echo "docker compose"
    else
        return 1
    fi
}

# Set the docker compose command
DOCKER_COMPOSE=$(get_docker_compose)
if [ $? -ne 0 ]; then
    print_error "Docker Compose is not available on your system."
    echo ""
    print_status "Please install Docker Compose:"
    echo ""
    echo "For Arch Linux:"
    echo "  sudo pacman -S docker-compose"
    echo ""
    echo "For Ubuntu/Debian:"
    echo "  sudo apt update && sudo apt install docker-compose-plugin"
    echo ""
    echo "For other systems, visit: https://docs.docker.com/compose/install/"
    echo ""
    exit 1
fi

# Function to show help
show_help() {
    echo "Betaflight Configurator Docker Development Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start, up     Start the development server (default)"
    echo "  stop, down    Stop the development server"
    echo "  restart       Restart the development server"
    echo "  build         Build/rebuild the Docker image"
    echo "  logs          Show container logs"
    echo "  shell         Open a shell in the running container"
    echo "  test          Run tests in Docker"
    echo "  build-prod    Build production version"
    echo "  clean         Clean up containers and images"
    echo "  status        Show container status"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start      # Start development server"
    echo "  $0 logs       # View logs"
    echo "  $0 shell      # Get shell access"
}

# Function to start development server
start_dev() {
    print_status "Starting Betaflight Configurator development server..."
    check_docker
    
    print_status "Building and starting containers..."
    $DOCKER_COMPOSE up --build
    
    print_success "Development server started!"
    print_status "Access the application at:"
    echo "  - Development: http://localhost:8000"
    echo "  - Preview: http://localhost:8080"
}

# Function to stop development server
stop_dev() {
    print_status "Stopping Betaflight Configurator development server..."
    $DOCKER_COMPOSE down
    print_success "Development server stopped!"
}

# Function to restart development server
restart_dev() {
    print_status "Restarting Betaflight Configurator development server..."
    $DOCKER_COMPOSE down
    $DOCKER_COMPOSE up --build
    print_success "Development server restarted!"
}

# Function to build Docker image
build_image() {
    print_status "Building Docker image..."
    check_docker
    $DOCKER_COMPOSE build --no-cache
    print_success "Docker image built successfully!"
}

# Function to show logs
show_logs() {
    print_status "Showing container logs..."
    $DOCKER_COMPOSE logs -f betaflight-dev
}

# Function to open shell in container
open_shell() {
    print_status "Opening shell in development container..."
    if $DOCKER_COMPOSE ps | grep -q "betaflight-dev.*Up"; then
        $DOCKER_COMPOSE exec betaflight-dev sh
    else
        print_warning "Container is not running. Starting it first..."
        $DOCKER_COMPOSE run --rm betaflight-dev sh
    fi
}

# Function to run tests
run_tests() {
    print_status "Running tests in Docker..."
    check_docker
    $DOCKER_COMPOSE --profile test up --build betaflight-test
    print_success "Tests completed!"
}

# Function to build production version
build_production() {
    print_status "Building production version..."
    check_docker
    $DOCKER_COMPOSE --profile build up --build betaflight-build
    print_success "Production build completed!"
}

# Function to clean up
cleanup() {
    print_status "Cleaning up Docker resources..."
    $DOCKER_COMPOSE down -v --remove-orphans
    docker system prune -f
    print_success "Cleanup completed!"
}

# Function to show status
show_status() {
    print_status "Container status:"
    $DOCKER_COMPOSE ps
    echo ""
    print_status "Docker system info:"
    docker system df
}

# Main script logic
case "${1:-start}" in
    "start"|"up")
        start_dev
        ;;
    "stop"|"down")
        stop_dev
        ;;
    "restart")
        restart_dev
        ;;
    "build")
        build_image
        ;;
    "logs")
        show_logs
        ;;
    "shell")
        open_shell
        ;;
    "test")
        run_tests
        ;;
    "build-prod")
        build_production
        ;;
    "clean")
        cleanup
        ;;
    "status")
        show_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
