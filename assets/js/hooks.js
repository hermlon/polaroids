let Hooks = {}

Hooks.ImageLoad = {
    mounted() {
        console.log(this.el)
        if (this.el.previousElementSibling == null) {
            this.el.classList.add("opacity-0")
            setTimeout(() => {
                this.el.classList.remove("opacity-0")
            }, 400)
        }
    }
}

export { Hooks }