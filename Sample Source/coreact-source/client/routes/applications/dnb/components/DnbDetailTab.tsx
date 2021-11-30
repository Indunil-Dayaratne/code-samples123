import * as React from 'react';

import {
  Tabs,
  SkeletonBodyText
} from '@shopify/polaris';
export class DnbDetailTab extends React.Component<any,any> {

  constructor(props : any) {
    super(props);

    this.onLoadingChanged = this.onLoadingChanged.bind(this);

    this.state = {
      isLoading: true
    }
  }

  renderContent() {
    return (<div>Loaded</div>);
  }

  renderLoading() {
    return (
      <SkeletonBodyText />
    );
  }

  onLoadingChanged(isLoading: boolean) {
    this.setState({ isLoading });
  }

  render() {

    const { tabId, panelId} = this.props;

    return (
      <Tabs.Panel tabID={tabId} id={panelId}>
        { !this.state.isLoading ? this.renderContent() : this.renderLoading() }
      </Tabs.Panel>
    )
  }
}
