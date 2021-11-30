<template>
    <b-nav :vertical="!horizontal" pills>
        <template v-for="link in links">
            <b-nav-item :key="link.name || link.path" 
                :to="{ path: link.path, name: link.name }" 
                :class="['stratus-menu-link d-flex justify-content-center align-items-center', horizontal ? 'dir-h' : '']"
                active-class="active"
                :disabled="!!link.disabled">
                <template v-if="!!link.icon">
                    <fa-icon :icon="link.icon" class="nav-icon"></fa-icon>
                    <span :class="[!horizontal ? 'stratus-menu-link-title' : '']">{{link.title}}</span>
                </template>
                <template v-else>
                    {{link.title}}
                </template>
                <b-spinner v-if="link.spinner" small/>
            </b-nav-item>
        </template>
    </b-nav>
</template>

<script>
    export default {
        props: {
            links: {
                type: Array,
                required: true
            },
            horizontal: {
                type: Boolean,
                default: false
            }
        },
        computed: {
            
        }
    }
</script>

<style lang="scss" scoped>
$link-border: 0.15rem;
$link-margin: 0.3rem;

.nav-icon {
    font-size: 1.1rem;
}

.stratus-menu-link-title {
    display: none;
}

.stratus-menu-link {
    position: relative;
    margin-bottom: $link-margin;
    user-select: none;

    &.dir-h {
        margin-bottom: 0;
        margin-right: $link-margin;
    }

    .nav-link {
        position: relative;
    }
    
    &:hover {  
        .nav-link {
            & , .stratus-menu-link-title {
                box-shadow: 7px 5px 8px lightgray;
                border: $link-border  #20a8d8 solid;
                padding: calc(0.5rem - #{$link-border}) calc(1rem - #{$link-border});
            }

            .stratus-menu-link-title {
                border-left: none;
            }

            &.disabled {
                & , .stratus-menu-link-title {
                    border-color: grey;
                    box-shadow: none;
                }
            }
        }

        // .nav-link {
        //     border: $link-border #20a8d8 solid;
        //     padding: calc(0.5rem - #{$link-border}) calc(1rem - #{$link-border});
        // }  
        
        .stratus-menu-link-title {
            display: block;
            position: absolute;
            left: 43px;
            top: -$link-border;
            background: white;
            z-index: 10;
            width: max-content;
            //padding: calc(0.5rem - #{$link-border}) 1rem;
            border-radius: 0 0.25rem 0.25rem 0;
            //border: $link-border #20a8d8 solid;
            border-left: none;
        }

        .active .stratus-menu-link-title {
            background: #20a8d8;
        }
    }
}
</style>