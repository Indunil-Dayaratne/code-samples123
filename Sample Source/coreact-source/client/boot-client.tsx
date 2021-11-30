
import * as React from 'react';
import * as ReactDOM from 'react-dom';


let render = () => {
  const MainApp = require('../client/App').default;

  ReactDOM.hydrate(
    <MainApp />,
    document.getElementById('react-app')

  )
}

// Allow Hot Module Replacement
if (module.hot) {
    module.hot.accept('../client/App', () => {
      const NextApp = require('../client/App').default;
        ReactDOM.hydrate(
          <NextApp />,
          document.getElementById('react-app')
        );
  });

}

render();
