#include <iostream>
#include <random>
#include <chrono>
#include <SFML/Graphics.hpp>

#include <functional> // Para std::function

class Button {
public:
    sf::RectangleShape shape;
    sf::Text text;
    std::function<void()> action;

    Button(const sf::Vector2f& size, const sf::Vector2f& position, 
           const std::string& label, const sf::Font& font, 
           const sf::Color& color, std::function<void()> onClick) 
        : action(onClick) {
        
        shape.setSize(size);
        shape.setPosition(position);
        shape.setFillColor(color);

        text.setString(label);
        text.setFont(font);
        text.setCharacterSize(20);
        text.setFillColor(sf::Color::White);
        text.setPosition(position.x + 10, position.y + 5);
    }

    bool isClicked(const sf::Vector2i& mousePos) const {
        return shape.getGlobalBounds().contains(mousePos.x, mousePos.y);
    }

    void draw(sf::RenderWindow& window) const {
        window.draw(shape);
        window.draw(text);
    }
};

int main()
{
    unsigned int ancho = 640;
    unsigned int alto = 360;
    unsigned int size = ancho * alto;
    unsigned int *tablero = new unsigned int [size];
    unsigned int *vecinos = new unsigned int [size];

    sf::RenderWindow* window = new sf::RenderWindow(sf:: VideoMode({ ancho, alto }), "Tutorials");
    window->setFramerateLimit(10);

    // --- Fuente para los botones ---
    sf::Font font;
    if (!font.loadFromFile("/usr/share/fonts/truetype/freefont/FreeSans.ttf")) 
    {
        // Alternativas comunes:
        // - "DejaVuSans.ttf"
        // - "LiberationSans-Regular.ttf"
        // - "Ubuntu-R.ttf" (si tienes instaladas las fuentes Ubuntu)
        std::cerr << "Error cargando la fuente\n";
        // Continúa sin fuente en lugar de return -1
    }

    // --- Botones ---
    bool paused = false;
    bool stepOnce = false;

    Button btnPause
    (
        sf::Vector2f(100, 30), sf::Vector2f(10, 10), "Pausa", font, 
        sf::Color(70, 70, 70), [&paused]() { paused = !paused; }
    );

    Button btnStep
    (
        sf::Vector2f(100, 30), sf::Vector2f(120, 10), "Paso", font,
        sf::Color(70, 70, 70), [&stepOnce, &paused]() 
        { 
            stepOnce = true; 
            paused = true; // Pausa después de un paso
        }
    );

    sf::Image image;
    image.create(ancho, alto, sf::Color::Transparent); 

    sf::Texture texture;
    if (!texture.loadFromImage(image)) {

        std::cerr << "Error al crear la textura desde la imagen\n";
    }

    sf::Sprite sprite(texture);

    int dir[8] = {1, int(ancho)+1, int(ancho), int(ancho)-1, -1, -int(ancho)-1, -int(ancho), -int(ancho)+1};

    std::default_random_engine randomNum;
    int semilla = std::chrono:: steady_clock::now().time_since_epoch ().count();
    randomNum.seed(semilla);

    for(unsigned int i = 0; i < size; ++i) 
    {
        std::uniform_int_distribution onoff(0, 1);
        tablero[i] = onoff(randomNum);
        vecinos[i] = 0;
    }

    while (window->isOpen()) 
    {
        sf::Event event;
        while (window->pollEvent(event)) {
            if (event.type == sf::Event::Closed) 
            {
                window->close();
            }
            else if (event.type == sf::Event::MouseButtonPressed) 
            {
                if (event.mouseButton.button == sf::Mouse::Left) 
                {
                    sf::Vector2i mousePos = sf::Mouse::getPosition(*window);
                    
                    // Verificar clic en botones
                    if (btnPause.isClicked(mousePos)) btnPause.action();
                    if (btnStep.isClicked(mousePos)) btnStep.action();
                }
            }
        }
        
        if (!paused || stepOnce) 
        {
            for(unsigned int i = 0; i < size; ++i) 
            {
                if(tablero[i] == 0) 
                {
                    continue;
                }
                for(int j = 0; j < 8; ++j) 
                {
                    int index = (i + dir[j] + size) % size;
                    ++vecinos[index];
                }
            }
            for(unsigned int i = 0; i < size; ++i) 
            {
                //If off && neighbors == 3 -> On
                //If on && neighbors < 2 || neighbors > 3 -> Off
                if(tablero[i] == 0 && vecinos[i] == 3) 
                {
                    tablero[i] = 1;
                }
                else if(tablero[i] == 1 && (vecinos[i] < 2 || vecinos[i] > 3)) 
                {
                    tablero[i] = 0;
                }
                sf::Color color = tablero[i] == 1 ? sf::Color:: White: sf::Color::Black;
                unsigned int x = i % ancho;
                unsigned int y = floor(i / ancho);
                sf::Vector2u pos = sf::Vector2u(x, y);
                image.setPixel(x, y, color);
                vecinos[i] = 0;
            }
        }        
        if (stepOnce) 
        {
            stepOnce = false;  // Resetear después de un paso
        }
        texture.update(image);
        //Render
        window->clear();
        window->draw(sprite); // Dibuja el tablero
        btnPause.draw(*window); // Dibuja los botones
        btnStep.draw(*window);
        window->display();
    }

    delete window;
    delete[] tablero;
    delete[] vecinos;
    return 0;
}