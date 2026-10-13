// <elmcn-dialog>, the thin custom element behind UI.Dialog. Import it once from your
// JavaScript entry point:
//
//     import "./UI/elmcn-dialog";


export class ElmcnDialog extends HTMLElement {
  #ready = false;
  static observedAttributes = ["open"];

  connectedCallback() {
    this.#connected();
    this.#ready = true;
  }

  attributeChangedCallback() {
    if (this.#ready) {
      this.#connected()
    }
  }

  #connected() {
    const dialog = this.querySelector('dialog');
    const open = this.getAttribute('open') !== null;

    if (dialog && open && !dialog.open) {
      dialog.showModal();
    } else if (dialog && dialog.open) {
      // Close once the exit transition ends, unless the dialog was opened again
      // meanwhile. Only the dialog's own children count, the overlay and the
      // panel: a button or input inside also transitions when a click moves
      // focus away from it, and its `transitionend` bubbles up here first.
      const onTransitionEnd = (event: TransitionEvent) => {
        if (!(event.target instanceof Element) || event.target.parentElement !== dialog) return;
        dialog.removeEventListener('transitionend', onTransitionEnd);
        if (this.getAttribute('open') === null) dialog.close();
      };

      dialog.addEventListener('transitionend', onTransitionEnd);
    }
  }
}

if (!customElements.get("elmcn-dialog")) customElements.define("elmcn-dialog", ElmcnDialog);
