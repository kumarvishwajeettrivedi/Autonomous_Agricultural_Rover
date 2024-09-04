#include<iostream>
#include<string>
using namespace std;

class Rover {
    int x;
    int y;
    char orientation;

public:
    Rover();
    Rover(int, int, char);
    void rotateLeft();
    void rotateRight();
    void movePosition();
    void displayPosition();
};

Rover::Rover() : x(0), y(0), orientation('N') {}

Rover::Rover(int positionX, int positionY, char Orientation) 
    : x(positionX), y(positionY), orientation(Orientation) {}

void Rover::displayPosition() {
    cout << x << " " << y << " " << orientation << endl;
}

void Rover::rotateLeft() {
    switch(orientation) {
        case 'N': orientation = 'W'; break;
        case 'W': orientation = 'S'; break;
        case 'S': orientation = 'E'; break;
        case 'E': orientation = 'N'; break;
    }
}

void Rover::rotateRight() {
    switch(orientation) {
        case 'N': orientation = 'E'; break;
        case 'E': orientation = 'S'; break;
        case 'S': orientation = 'W'; break;
        case 'W': orientation = 'N'; break;
    }
}

void Rover::movePosition() {
    switch(orientation) {
        case 'N': y++; break;
        case 'S': y--; break;
        case 'E': x++; break;
        case 'W': x--; break;
    }
}

int main() {
    int x, y;
    char orient;
    
    
    cout << "Enter initial position and orientation (x y orientation): ";
    cin >> x >> y >> orient;
   
    if (orient != 'N' && orient != 'S' && orient != 'E' && orient != 'W') {
        cout << "Invalid orientation! Use N, S, E, or W." << endl;
        return 1;
    }
    
    Rover firstRover(x, y, orient);

  
    cout << "Initial Position: ";
    firstRover.displayPosition();

    string roverMovement;
    cout << "Enter movement commands (L for left, R for right, M for move): ";
    cin >> roverMovement;

   
    for (char command : roverMovement) {
        switch(command) {
            case 'L': firstRover.rotateLeft(); break;
            case 'R': firstRover.rotateRight(); break;
            case 'M': firstRover.movePosition(); break;
            default: 
                cout << "Invalid command " << command << "! Use L, R, or M." << endl;
                return 1;
        }
    }

    
    cout << "Final Position: ";
    firstRover.displayPosition();

    return 0;
}
