Carter Bankowski
4930 2098

Added a Lightmode Darkmode toggle button. When clicked, will swap light mode and dark mode themes on page. The site defaults to dark mode. Relavant code can be found at the beginning of frontend.impl.jac lines 3-9 and frontend.cl.jac 207-232. Also, style.css now has two sets of rules one for each light and dark.


App can be run by installing jac dependencies, setting up a gemini api key and running...

$ export GOOGLE_API_KEY="the-key" --> NOTE: didnt post my actual key becuase this is a public repo

then

$ jac start main.jac



# my-todo-app

A Jac client-side application with React support.

## Project Structure

```
my-todo-app/
├── jac.toml              # Project configuration
├── main.jac              # Main application entry
├── components/           # Reusable components
│   └── Button.cl.jac     # Example Jac component
├── assets/               # Static assets (images, fonts, etc.)
└── build/                # Build output (generated)
```

## Getting Started

Start the development server:

```bash
jac start main.jac
```

## Components

Create Jac components in `components/` as `.cl.jac` files and import them:

```jac
cl import from .components.Button { Button }
```

## Adding Dependencies

Add npm packages with the --cl flag:

```bash
jac add --cl react-router-dom
```
