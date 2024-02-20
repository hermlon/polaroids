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

Hooks.ImageShare = {
    mounted() {
        const files = [ new File([""], "test.jpeg") ]
        if (!navigator.canShare({ files })) {
            this.el.disabled = true
        }

        this.handleEvent("share", async ({ image }) => {
            const response = await fetch(image, { cache: "no-cache" })
            const fileBinary = await response.blob()
            const files = [
                new File([fileBinary], image.split("/").reverse()[0], {
                    type: fileBinary.type,
                    lastModified: new Date().getTime(),
                })
            ]
            const share = {
                files
            }
            try {
                await navigator.share(share);
            } catch (error) {
                console.error(error)
            }
        })
    }
}

export { Hooks }